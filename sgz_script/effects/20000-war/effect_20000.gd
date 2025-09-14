extends "res://script/effects_base.gd"

const KEY_MENU_ITEMS = "列表显示"
const KEY_MENU_VALUES = "列表值"

const KEY_MOVE_TYPE = "移动"
const KEY_MOVE_AP_COST = "行军消耗机动力"
const KEY_MOVE_TARGET_BLOCK = "行军地形"

# 初始化局部变量，应在 _init() 中调用
func init_vars():
	ske = SkillHelper.read_skill_effectinfo()
	if ske != null:
		actorId = ske.skill_actorId
		triggerId = ske.trigger_Id
		me = ske.get_war_actor()
		actor = ActorHelper.actor(actorId)
	wf = DataManager.get_current_war_fight()
	bf = DataManager.get_current_battle_fight()
	if DataManager.get_current_scene_id() == 20000:
		var current_scene = SceneManager.current_scene()
		if current_scene != null:
			map = current_scene.war_map
	return

func check_trigger_correct() -> bool:
	if ske == null or me == null:
		return false
	var method = "on_trigger_{0}".format([ske.trigger_Id])
	if has_method(method):
		return call(method)
	return false

func check_AI_perform() -> bool:
	if me == null:
		return false
	if me.get_buff_label_turn(["禁用主动技"]) > 0:
		return false
	# 保留现场
	var prevSke = ske
	var key = "战争.主动技.允许.{0}".format([actorId])
	DataManager.set_env(key, "1")
	SkillHelper.auto_trigger_skill(actorId, 20023)
	# 恢复现场
	SkillHelper.save_skill_effectinfo(prevSke)
	if DataManager.get_env_str(key) != "1":
		return false
	return check_AI_perform_20000()

# 分离这个方法主要是为了包装基本检查
# 20000 技能应该重载 check_AI_perform_20000
# 而不是直接重载 check_AI_perform
func check_AI_perform_20000() -> bool:
	return false

#显示并等待选择目标位置
func wait_choose_positions(positions:PoolVector2Array, msg:String="移动到何处？", nextViewModel:int=2000) -> void:
	map.clear_can_choose_actors()
	map.show_color_block_by_position(positions)
	DataManager.set_env("可选目标", positions)
	DataManager.set_target_position(positions[0])
	SceneManager.show_unconfirm_dialog(msg, actorId)
	LoadControl.set_view_model(nextViewModel)
	return

#选择目标时都用此方法
func wait_choose_actors(targets:PoolIntArray, msg:String="对何人发动{0}?",through_wall:bool = false)->bool:
	var centers = get_skill_centers(me)
	if me.is_defender():
		through_wall = true;#守方允许穿墙
	if not through_wall:
		var newTargets = []
		for targetId in targets:
			if targetId in newTargets:
				continue
			var wa = DataManager.get_war_actor(targetId)
			for center in centers:
				if check_can_choose(me, center, wa.position):
					newTargets.append(targetId)
					break
		targets = newTargets
	
	if targets.empty():
		map.cursor.hide()
		msg = "没有可发动【{0}】的目标".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2888)
		return false

	map.cursor.show()
	set_env("可选目标", targets)
	var firstTargetId = targets[0]
	var lastTargetId = get_target_id()
	if lastTargetId in targets:
		firstTargetId = lastTargetId
	var wa = DataManager.get_war_actor(firstTargetId)
	map.set_cursor_location(wa.position, true)
	set_env("武将", firstTargetId)
	map.show_can_choose_actors(targets, me.actorId);#大地图显示可选目标
	msg = msg.format([skill_name()]);
	SceneManager.show_actor_info(firstTargetId, true, msg)
	map.next_shrink_actors = [firstTargetId]
	return true

#对目标执行什么效果
func choose_actor_then(targetId:int,next_flow:String):
	var targetActor = ActorHelper.actor(targetId)
	# 谦逊比较特别，直接判断了
	if actor.get_wisdom() < 90:
		if SkillHelper.actor_has_skills(targetId, ["谦逊"], false):
			var msg = "君子之道，思危，思退\n（{0}【谦逊】\n（规避{1}的【{2}】".format([
				targetActor.get_name(), actor.get_name(), ske.skill_name,
			])
			LoadControl._error(msg, targetId)
			return false
	if actor.get_moral() <= targetActor.get_moral() - 20:
		if SkillHelper.actor_has_skills(targetId, ["气狭"], false):
			var msg = "{0}何人也，不足与论！\n（{1}【气狭】\n（规避{2}的【{3}】".format([
				DataManager.get_actor_naughty_title(actorId, targetId),
				targetActor.get_name(), actor.get_name(), ske.skill_name,
			])
			LoadControl._error(msg, targetId)
			return false
	if targetActor.get_moral() <= actor.get_moral() - 20:
		if SkillHelper.actor_has_skills(actorId, ["气狭"], false):
			var msg = "{0}何人也，目无此人！\n（{1}【气狭】\n（无法对{2}发动技能".format([
				DataManager.get_actor_naughty_title(targetId, actorId),
				actor.get_name(), targetActor.get_name(),
			])
			LoadControl._error(msg, actorId)
			return false

	ske.targetId = targetId
	FlowManager.add_flow(next_flow)
	return

#默认可选距离6
func get_choose_distance()->int:
	if me == null:
		return 6
	return 6 + int(SkillRangeBuff.max_val_for_actor("技能距离加成", actorId, 0))

# 判断技能是否可以选择
func check_can_choose(wa:War_Actor, from:Vector2, target:Vector2)->bool:
	if from == target:
		return true
	var distance = get_choose_distance()
	var map = SceneManager.current_scene().war_map
	map.aStar.update_map_for_actor(wa)
	var path = map.aStar.get_skill_path(from, target, distance)
	return path.size() >= 2

#回到诱发技选择时
func back_to_induce_ready():
	LoadControl.end_script();
	var st = SkillHelper.get_current_skill_trigger()
	LoadControl.load_script("res://resource/sgz_script/war/player_skill_induce.gd")
	var current_controlNo = int(DataManager.common_variable["诱发控制"]);
	if(current_controlNo>=0):
		FlowManager.add_flow("induce_player_ask");
	else:
		#AI暂时发动诱发技
		FlowManager.add_flow("induce_AI_choose");

#回到主动技菜单
func back_to_skill_menu():
	if map != null:
		map.cursor.hide()
		map.clear_can_choose_actors()
	LoadControl.end_script()
	LoadControl.load_script("res://resource/sgz_script/war/player_skill_menu.gd")
	# 暂不支持 AI 主动技
	FlowManager.add_flow("skill_menu")
	return

# 信息发动后的结果确认
func wait_for_skill_result_confirmation(nextFlow:String="player_skill_end_trigger"):
	if Global.wait_for_confirmation(nextFlow):
		map.clear_can_choose_actors()
		if nextFlow == "":
			LoadControl.end_script()
	return

# 发动主动技时，等待数值输入
func wait_for_number_input(nextFlow:String):
	var conNumberInput = SceneManager.input_numbers.get_current_input_node()
	var number:int = conNumberInput.get_number()

	if Global.is_action_pressed_BY():
		if not SceneManager.input_numbers.is_msg_complete():
			return
		back_to_skill_menu()
		return

	if Input.is_action_just_pressed("ANALOG_UP"):
		conNumberInput.cursor_number_up()
	if Input.is_action_just_pressed("ANALOG_DOWN"):
		conNumberInput.cursor_number_down()
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		conNumberInput.cursor_move_left()
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		conNumberInput.cursor_move_right()
	if Input.is_action_just_pressed("EMU_SELECT"):
		conNumberInput.set_number(conNumberInput.min_number)
	if Input.is_action_just_pressed("EMU_START"):
		conNumberInput.set_number(conNumberInput.max_number)
	if Global.is_action_pressed_AX():
		if not SceneManager.input_numbers.is_msg_complete():
			SceneManager.input_numbers.show_all_msg()
			return
		if number == 0:
			#不能给0
			return
		LoadControl.set_view_model(-1)
		DataManager.set_env("数值", number)
		FlowManager.add_flow(nextFlow)
	return

func wait_for_multiple_number_input(nextFlow:String) -> void:
	var con = SceneManager.input_numbers
	var current = con.get_current_input_node()
	if Input.is_action_just_pressed("ANALOG_UP"):
		current.cursor_number_up()
	if Input.is_action_just_pressed("ANALOG_DOWN"):
		current.cursor_number_down()
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		current.cursor_move_left()
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		current.cursor_move_right()
	if Input.is_action_just_pressed("EMU_SELECT"):
		current.set_number(current.min_number)
	if Input.is_action_just_pressed("EMU_START"):
		current.set_number(current.max_number)
	if Global.is_action_pressed_BY():
		if not con.is_msg_complete():
			return
		if con.pre_input_index():
			current = SceneManager.input_numbers.get_current_input_node()
			current.set_number(0, true)
			return
		back_to_skill_menu()
		return
	if not Global.is_action_pressed_AX():
		return
	if not con.is_msg_complete():
		con.show_all_msg()
		return

	var numbers = con.get_numbers()
	DataManager.set_env("多项数值", numbers)
	var total = 0
	for n in numbers:
		total += n
	var number = current.get_number()
	if not con.is_last_input():
		con.next_input_index()
		return
	elif total > 0:
		LoadControl.set_view_model(-1)
		FlowManager.add_flow(nextFlow)
	return

# 选择目标部队，支持主动技和诱发计
func wait_for_choose_actor(nextFlow:String, isActiveSkill:bool=true, canBack:bool=true, backFlow:String=""):
	var distance = get_choose_distance()
	if me != null:
		map.draw_outline_by_range(me.position, distance)
	var targets = get_env_int_array("可选目标")
	if targets.empty():
		return false
	var current = get_env_int("武将")
	var index = targets.find(current)
	if index < 0:
		index = 0
		current = targets[0]
		set_env("武将", current)

	var msg = update_choose_actor_message(current)
	SceneManager.show_actor_info(current, false, msg)

	# 测试 debug 显示
	if DataManager.is_test_player():
		var target = DataManager.get_war_actor(current)
		if target != null:
			var path = map.aStar.get_skill_path(me.position, target.position, distance)
			if path.size() > 0:
				map.show_color_block_by_position(path)#, map.SELECTOR_COLOR)

	if Global.is_action_pressed_BY():
		if not canBack:
			return
		if not SceneManager.dialog_msg_complete():
			return
		map.draw_outline_by_range(Vector2.ZERO, 0)
		LoadControl.set_view_model(-1)
		if backFlow != "":
			FlowManager.add_flow(backFlow)
			return
		if isActiveSkill:
			back_to_skill_menu()
		else:
			back_to_induce_ready()
		return

	if Input.is_action_just_pressed("ANALOG_UP"):
		index = ActorHelper.find_next_war_actor(targets, index, Vector2.UP)
		if targets[index] == current:
			return
	if Input.is_action_just_pressed("ANALOG_DOWN"):
		index = ActorHelper.find_next_war_actor(targets, index, Vector2.DOWN)
		if targets[index] == current:
			return
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		index = ActorHelper.find_next_war_actor(targets, index, Vector2.LEFT)
		if targets[index] == current:
			return
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		index = ActorHelper.find_next_war_actor(targets, index, Vector2.RIGHT)
		if targets[index] == current:
			return
	var wa = DataManager.get_war_actor(current)
	if targets[index] != current:
		current = targets[index]
		set_env("武将", current)
		wa = DataManager.get_war_actor(current)
	if wa != null and map.cursor_position != wa.position:
		map.set_cursor_location(wa.position, true)
		msg = update_choose_actor_message(wa.actorId)
		SceneManager.show_actor_info(wa.actorId, false, msg)
		map.next_shrink_actors = [wa.actorId]

	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	map.draw_outline_by_range(Vector2.ZERO, 0)
	LoadControl.set_view_model(-1)
	set_env("目标", targets[index])
	choose_actor_then(targets[index], nextFlow)
	return

# 选择目标位置，支持主动技和诱发计
func wait_for_choose_position(nextFlow:String, isActiveSkill:bool=true, backFlow:String="", canBack:bool=true):
	var targetPositions = DataManager.get_env_array("可选目标")
	var array = []
	if typeof(targetPositions) != TYPE_ARRAY:
		for piece in str(targetPositions).split("),"):
			piece = piece.replace("[", "")
			piece = piece.replace("]", "")
			piece = piece.replace("(", "")
			piece = piece.replace(" ", "")
			var x = int(piece.split(",")[0])
			var y = int(piece.split(",")[1])
			array.append(Vector2(x,y))
	elif typeof(targetPositions[0]) != TYPE_VECTOR2:
		for pos in targetPositions:
			var piece = str(pos)
			piece = piece.replace("(", "")
			piece = piece.replace(")", "")
			var x = int(piece.split(",")[0])
			var y = int(piece.split(",")[1])
			array.append(Vector2(x,y))
	else:
		array = PoolVector2Array(targetPositions)
	var current = DataManager.get_target_position()
	var index = array.find(current)
	var map = SceneManager.current_scene().war_map
	map.set_cursor_location(current, true)
	map.cursor.show()

	if canBack and Global.is_action_pressed_BY():
		if not SceneManager.dialog_msg_complete():
			return
		if backFlow != "":
			FlowManager.add_flow(backFlow)
			return
		if isActiveSkill:
			back_to_skill_menu()
		else:
			back_to_induce_ready()
		return

	var UDLR:bool = false
	if Input.is_action_just_pressed("ANALOG_UP"):
		index = ActorHelper.find_next_war_position(array, index, Vector2.UP)
		if array[index] == current:
			return
		UDLR = true
	if Input.is_action_just_pressed("ANALOG_DOWN"):
		index = ActorHelper.find_next_war_position(array, index, Vector2.DOWN)
		if array[index] == current:
			return
		UDLR = true
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		index = ActorHelper.find_next_war_position(array, index, Vector2.LEFT)
		if array[index] == current:
			return
		UDLR = true
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		index = ActorHelper.find_next_war_position(array, index, Vector2.RIGHT)
		if array[index] == current:
			return
		UDLR = true
	if UDLR:
		current = array[index]
		map.set_cursor_location(current, true)
		DataManager.set_target_position(current)

	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	LoadControl.set_view_model(-1)
	FlowManager.add_flow(nextFlow)
	return

# 选择任意目标位置，支持主动技和诱发计
func wait_for_free_position(nextFlow:String, isActiveSkill:bool=true, backFlow:String="", rng:int=6):
	if Global.is_action_pressed_BY():
		if not SceneManager.dialog_msg_complete():
			return
		map.draw_outline_by_range(Vector2.ZERO, 0)
		if backFlow != "":
			FlowManager.add_flow(backFlow)
			return
		if isActiveSkill:
			back_to_skill_menu()
		else:
			back_to_induce_ready()
		return

	if me != null:
		map.draw_outline_by_range(me.position, rng)
	if Input.is_action_just_pressed("ANALOG_UP"):
		map.cursor_move_up()
	if Input.is_action_just_pressed("ANALOG_DOWN"):
		map.cursor_move_down()
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		map.cursor_move_left()
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		map.cursor_move_right()

	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	map.draw_outline_by_range(Vector2.ZERO, 0)
	LoadControl.set_view_model(-1)
	FlowManager.add_flow(nextFlow)
	return

# 从列表中选择技能目标
func wait_for_choose_skill(nextFlow:String, isActiveSkill:bool=true, allowBack:bool=true, isMultiple:bool=false, multipleLimit:int=4):
	var top = SceneManager.lsc_menu_top
	if Input.is_action_just_pressed("EMU_SELECT"):
		var list = DataManager.get_env_array("列表值")
		var currentSkill = ""
		if top.lsc.cursor_index >= 0 or top.lsc.cursor_index < list.size():
			var current = list[top.lsc.cursor_index]
			# 兼容一些特殊技能的列表，比如奋困
			currentSkill = current.split("#")[0]
			# 兼容一些特殊技能的列表，比如易经
			currentSkill = currentSkill.split("（")[0]
		if currentSkill != "":
			var sr = SkillInfo.SkillRecord.new(currentSkill, actorId)
			var content = "[center][color=yellow]【{0}】[/color]{1}，{2}[/center]".format([
				sr.name, sr.scene, sr.category
			])
			content += "\n\n" + sr.full_description()
			top.set_TopMsg_text(content)
		if top.get_TopMsg_visible():
			top.set_TopMsg_visible(false)
		else:
			top.set_TopMsg_visible(true)
	top.set_memo("查看/隐藏技能说明")
	if isMultiple:
		return wait_for_select_multiple_item(multipleLimit, isActiveSkill, allowBack)
	wait_for_choose_item(nextFlow, isActiveSkill, allowBack)
	return

# 从列表中选择目标
func wait_for_choose_item(nextFlow:String, isActiveSkill:bool=true, allowBack:bool=true, backFlow:String="")->void:
	if allowBack and Global.is_action_pressed_BY():
		if not SceneManager.dialog_msg_complete():
			return
		if backFlow != "":
			LoadControl.set_view_model(-1)
			FlowManager.add_flow(backFlow)
			return
		if isActiveSkill:
			back_to_skill_menu()
		else:
			back_to_induce_ready()
		return

	if Input.is_action_just_pressed("ANALOG_UP"):
		SceneManager.lsc_menu_top.lsc.move_up()
	if Input.is_action_just_pressed("ANALOG_DOWN"):
		SceneManager.lsc_menu_top.lsc.move_down()
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		SceneManager.lsc_menu_top.lsc.move_left()
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		SceneManager.lsc_menu_top.lsc.move_right()

	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	LoadControl.set_view_model(-1)
	var list = get_env_array("列表值")
	if list.size() <= SceneManager.lsc_menu_top.lsc.cursor_index:
		return
	var item = list[SceneManager.lsc_menu_top.lsc.cursor_index]
	set_env("目标项", item)
	FlowManager.add_flow(nextFlow)
	return

# 多选列表操作
func wait_for_select_multiple_item(limit:int, isActiveSkill:bool=true, allowBack:bool=true)->int:
	var lsc = SceneManager.lsc_menu_top.lsc
	if allowBack and Global.is_action_pressed_BY():
		if not SceneManager.dialog_msg_complete():
			return -1
		if isActiveSkill:
			back_to_skill_menu()
		else:
			back_to_induce_ready()
		return -1

	if Input.is_action_just_pressed("ANALOG_UP"):
		lsc.move_up()
	if Input.is_action_just_pressed("ANALOG_DOWN"):
		lsc.move_down()
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		lsc.move_left()
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		lsc.move_right()

	if not Global.is_action_pressed_AX():
		return -1
	if not SceneManager.dialog_msg_complete(true):
		return -1
	var items = lsc.items
	var idx = lsc.cursor_index
	if idx < 0 or idx >= items.size():
		return -1
	var selected = lsc.get_selected_list()
	if idx in selected:
		selected.erase(idx)
	elif selected.size() >= limit:
		return -1
	else:
		selected.append(idx)
	lsc.set_selected_by_array(selected)
	return idx

# 确保有足够的机动力
func assert_action_point(actorId:int, apCost:int)->bool:
	var wa = DataManager.get_war_actor(actorId)
	if wa.action_point < apCost:
		LoadControl._error("机动力不足，需 >= {0}".format([apCost]))
		return false
	return true

# 确保有足够的标记数
func assert_flag_count(actorId:int, flagSceneId:int, flagEffId:int, flagName:String, flagCost:int)->bool:
	var flags = SkillHelper.get_skill_flags_number(flagSceneId, flagEffId, actorId, flagName)
	if flags < flagCost:
		LoadControl._error("[{0}]不足，需 >= {1}".format([flagName, flagCost]))
		return false
	return true

# 确保有足够的体力
func assert_min_hp(actorId:int, minHP:int)->bool:
	var actor = ActorHelper.actor(self.actorId)
	if actor.get_hp() < minHP:
		LoadControl._error("体力不足，需 >= {0}".format([minHP]))
		return false
	return true

# 将队友作为技能准备发动的目标
func get_teammate_targets(me:War_Actor, distance:int=-1, allowWalls:bool=true, ignoreExtra:bool=false)->PoolIntArray:
	if distance < 0:
		distance = get_choose_distance()
	# 特殊距离，不用考虑扩展额外选区
	if distance > get_choose_distance():
		ignoreExtra = true
	var ret = []
	if me == null:
		return ret
	var centers = get_skill_centers(me, ignoreExtra)
	for wa in me.war_vstate().get_war_actors(false, true):
		if wa.actorId == me.actorId:
			continue
		if wa.is_puppet():
			continue
		if not allowWalls:
			var block = map.get_blockCN_by_position(wa.position)
			if block in StaticManager.CITY_BLOCKS_CN:
				continue
		for center in centers:
			var disv = wa.position - center
			if max(abs(disv.x), abs(disv.y)) <= distance:
				if not wa.actorId in ret:
					ret.append(wa.actorId)
				break
	return ret

# 将对手作为技能准备发动的目标
func get_enemy_targets(from:War_Actor, allowWalls:bool=false, distance:int=-1, ignoreExtra:bool=false)->PoolIntArray:
	if distance < 0:
		distance = get_choose_distance()
	# 特殊距离，不用考虑扩展额外选区
	if distance > get_choose_distance():
		ignoreExtra = true
	var map = SceneManager.current_scene().war_map
	var ret = []
	var centers = get_skill_centers(from, ignoreExtra)
	var wf = DataManager.get_current_war_fight()
	for wa in wf.get_war_actors(false, true):
		if not from.is_enemy(wa):
			continue
		if wa.is_puppet():
			continue
		if wa.get_buff_label_turn(["潜行"]) > 0:
			continue
		if not allowWalls:
			var blockCN = map.get_blockCN_by_position(wa.position)
			if blockCN in StaticManager.CITY_BLOCKS_CN:
				continue
		for center in centers:
			if Global.get_range_distance(wa.position, center) > distance:
				continue
			if not allowWalls and from.is_attacker() and not check_can_choose(from, center, wa.position):
				continue
			if not wa.actorId in ret:
				ret.append(wa.actorId)
			break
	return ret

# 将营帐内的武将作为技能准备发动的目标
func get_camp_targets(me:War_Actor)->PoolIntArray:
	var ret = []
	if me == null or me.disabled:
		return ret
	var wv = me.war_vstate()
	if wv == null:
		return ret
	for targetId in wv.camp_actors:
		ret.append(targetId)
	return ret

# 等待是否确认，决定去哪个分支
func wait_for_yesno(flowForYes:String, isActiveSkill:bool=true, backFlow:String="", allowBack:bool=true)->void:
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		SceneManager.actor_dialog.move_left()
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		SceneManager.actor_dialog.move_right()
	if Input.is_action_just_pressed("ANALOG_UP"):
		SceneManager.actor_dialog.move_up()
	if Input.is_action_just_pressed("ANALOG_DOWN"):
		SceneManager.actor_dialog.move_down()
	if allowBack and Global.is_action_pressed_BY():
		if not SceneManager.dialog_msg_complete(false):
			return
		if backFlow != "":
			FlowManager.add_flow(backFlow)
			return
		if isActiveSkill:
			back_to_skill_menu()
		else:
			back_to_induce_ready()
		return
	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	match SceneManager.actor_dialog.lsc.cursor_index:
		0:
			LoadControl.set_view_model(-1)
			FlowManager.add_flow(flowForYes)
		1:
			if backFlow != "":
				LoadControl.set_view_model(-1)
				FlowManager.add_flow(backFlow)
				return
			if isActiveSkill:
				back_to_skill_menu()
			else:
				back_to_induce_ready()
	return

# 重复播放多轮对话直到结束
func wait_for_pending_message(replayFlow:String, nextFlow:String="player_skill_end_trigger")->void:
	if not Global.wait_for_confirmation(""):
		return
	var pending = DataManager.get_env_array("对话PENDING")
	if not pending.empty():
		FlowManager.add_flow(replayFlow)
		return
	DataManager.unset_env("对话PENDING")
	if nextFlow == "":
		LoadControl.end_script()
		return
	FlowManager.add_flow(nextFlow)
	return

# 剧情对话
func play_dialog(actorId:int, msg:String, mood:int, nextViewModel:int, yn:bool=false, options:PoolStringArray=["是", "否"]):
	if actorId >= 0:
		map.camer_to_actorId(actorId, "draw_actors")
		map.update_ap(actorId)
		map.next_shrink_actors = [actorId]
	else:
		FlowManager.add_flow("draw_actors")
	DataManager.set_env("对话", msg)
	if nextViewModel == -1:
		LoadControl._error(msg, actorId, mood)
	else:
		if yn:
			SceneManager.show_yn_dialog(msg, actorId, mood, options)
		else:
			SceneManager.show_confirm_dialog(msg, actorId, mood)
		LoadControl.set_view_model(nextViewModel)
	return

# 根据环境变量修改行军机动力
# 若目标地形在允许范围内，则降低移动消耗
# 注意：当参数 targetBlocks 为空时，表示全地形
func reduce_move_ap_cost(targetBlocks:PoolStringArray, reduceAP:int)->bool:
	if not check_env([KEY_MOVE_TARGET_BLOCK, KEY_MOVE_AP_COST]):
		return false
	var costAP = get_env_int(KEY_MOVE_AP_COST)
	if costAP == 0:
		# 特殊情况，如果已经设定为 0，就不再处理了
		return false
	var blockName = get_env_str(KEY_MOVE_TARGET_BLOCK)
	if not targetBlocks.empty() and not blockName in targetBlocks:
		return false
	costAP = max(1, costAP - reduceAP)
	set_env(KEY_MOVE_AP_COST, costAP)
	return false

# 根据环境变量修改行军机动力
# 若目标地形在允许范围内，则移动消耗至多为 x
# 注意：当参数 targetBlocks 为空时，表示全地形
func set_max_move_ap_cost(targetBlocks:PoolStringArray, maxAP:int, exceptedBlocks:PoolStringArray=[])->bool:
	if not check_env([KEY_MOVE_TARGET_BLOCK, KEY_MOVE_AP_COST]):
		return false
	var costAP = int(get_env(KEY_MOVE_AP_COST))
	if costAP == 0:
		# 特殊情况，如果已经设定为 0，就不再处理了
		return false
	var blockName = str(get_env(KEY_MOVE_TARGET_BLOCK))
	if not targetBlocks.empty() and not blockName in targetBlocks:
		return false
	if not exceptedBlocks.empty() and blockName in exceptedBlocks:
		return false
	costAP = min(maxAP, costAP)
	set_env(KEY_MOVE_AP_COST, costAP)
	return false

# 根据环境变量判断当前移动模式
# 移动：1，回退：-1，不动：0，未知：-2
# 环境异常也返回 -2
func get_move_type()->int:
	if not check_env([KEY_MOVE_TYPE]):
		return -2
	return int(get_env(KEY_MOVE_TYPE))

# 设置环境变量改变计策消耗
func set_scheme_ap_cost(stratagem:String, cost:int)->bool:
	if stratagem != "ALL" and stratagem != get_env_str("计策.消耗.计策名"):
		return false
	var prev = DataManager.get_env_int("计策.消耗.所需")
	if prev == 9999:
		# 表示不可用
		return false
	if prev <= cost and cost < 9999:
		return false
	DataManager.set_env("计策.消耗.所需", cost)
	return true

# 回调函数，更新选择目标时显示的信息
# 子类如果要更新信息，可重写此函数
func update_choose_actor_message(targetId:int)->String:
	return ""

func start_battle_and_finish(fromId:int, targetId:int, source:String="", sourceActorId:int=-1, forcedTerrian:String=""):
	if source == "":
		source = ske.skill_name
	SkillHelper.remove_all_skill_trigger()
	DataManager.player_choose_actor = fromId
	set_env("武将", targetId)
	var logInfo = "- <y{0}>发动【<r{1}>】攻击<y{2}>".format([
		ActorHelper.actor(fromId).get_name(), source,
		ActorHelper.actor(targetId).get_name(),
	])
	if sourceActorId >= 0 and sourceActorId != fromId:
		logInfo = "- <y{0}>发动【<r{1}>】令<y{2}>攻击<y{3}>".format([
			ActorHelper.actor(sourceActorId).get_name(), source,
			ActorHelper.actor(fromId).get_name(),
			ActorHelper.actor(targetId).get_name(),
		])
	DataManager.record_war_log(logInfo)
	DataManager.clear_common_variable(["白兵"])
	DataManager.battle_units = []
	DataManager.battle_actors = []
	DataManager.set_env("战斗.强制地形", forcedTerrian)
	var player_attack = Global.load_script(DataManager.mod_path+"sgz_script/war/player_attack.gd")
	player_attack._go_to_battle(false, source, ske.will_auto_finish_turn())
	LoadControl.end_script()
	return

# 设置计策增减伤倍率，只可用于 20011 计算计策伤害的回调场合
# @param rate 增减百分比
# @param unique 是否只汇报一次
func change_scheme_damage_rate(rate:int, unique:bool=true)->bool:
	if rate == 0:
		return false
	var baseDamage = DataManager.get_env_int("计策.ONCE.基础伤害")
	if baseDamage <= 0:
		return false
	var damage = DataManager.get_env_int("计策.ONCE.伤害")
	if rate == -100:
		damage = 0
	else:
		damage = damage + int(baseDamage * rate / 100)
	damage = max(0, damage)
	DataManager.set_env("计策.ONCE.伤害", damage)
	var type = "增伤"
	if rate < 0:
		type = "减伤"
	if rate == -100:
		type = "免伤"
	var msg = "【{0}】{1}{2}%".format([
		ske.skill_name, type, abs(rate),
	])
	if not unique:
		var targetId = get_env_int("计策.ONCE.伤害武将")
		msg = "【{0}】令{1}{2}{3}%".format([
			ske.skill_name, ActorHelper.actor(targetId).get_name(),
			type, abs(rate),
		])
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(ske.skill_actorId) != ske.skill_actorId:
		msg = me.get_name() + msg
	# 改变比例的信息，一般来说只汇报一次
	se.append_result(ske.skill_name, msg, rate, ske.skill_actorId, unique)
	return true

# 设置计策增减伤数值，只可用于 20011 计算计策伤害的回调场合
# @param actorId 来源武将
# @param skill 来源技能
# @param val 增减数值
func change_scheme_damage_value(actorId:int, skill:String, val:int)->bool:
	var damage = get_env_int("计策.ONCE.伤害")
	var finalDamage = max(0, damage + val)
	set_env("计策.ONCE.伤害", finalDamage)
	var changed = finalDamage - damage
	if changed == 0:
		return false
	var targetId = get_env_int("计策.ONCE.伤害武将")
	var type = "减伤"
	if changed > 0:
		type = "增伤"
	var msg = "【{1}】对{0}{2}{3}".format([
		ActorHelper.actor(targetId).get_name(),
		skill, type, abs(changed),
	])
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(actorId) != actorId:
		msg = ActorHelper.actor(actorId).get_name() + msg
	# 改变具体数值的消息，需要多次汇报
	se.append_result(skill, msg, changed, actorId)
	return true

# 汇报技能结果，并开启多轮汇报
func report_skill_result_message(ske:SkillEffectInfo, nextViewModel:int, startingMessage:String="", startingMood:int=2, startingReporter:int=-1, notifySkill:bool=true)->void:
	# 默认由技能发动者汇报
	var wa = DataManager.get_war_actor(ske.skill_actorId)
	if wa == null and startingMessage != "":
		LoadControl.set_view_model(nextViewModel)
		return
	if startingMessage != "":
		if notifySkill:
			startingMessage += "\n（{0}发动【{1}】".format([
				wa.get_name(), ske.skill_name,
			])
		var msgs = ske.get_report_message()
		if not msgs.empty():
			DataManager.set_env("对话PENDING", msgs)
		# 同时汇报到日志
		ske.war_report()
		if startingReporter < 0:
			startingReporter = wa.actorId
		play_dialog(startingReporter, startingMessage, startingMood, nextViewModel)
		return
	var msgs = DataManager.get_env_array("对话PENDING")
	DataManager.unset_env("对话PENDING")
	if msgs.empty():
		# 初始化汇报内容
		msgs = ske.get_report_message()
		# 同时汇报到日志
		ske.war_report()
	if msgs.size() > 3:
		# 对话过长，拆分出一部分，其余分屏汇报
		DataManager.set_env("对话PENDING", msgs.slice(3, msgs.size()-1))
		msgs = msgs.slice(0, 2)
	var map = SceneManager.current_scene().war_map
	map.next_shrink_actors = []
	map.show_color_block_by_position([])
	map.draw_actors()
	play_dialog(-1, "\n".join(msgs), 2, nextViewModel)
	return

# 汇报计策结果，并开启多轮汇报
func report_stratagem_result_message(se:StratagemExecution, nextViewModel:int, startingMessage:String="", startingMood:int=2)->void:
	LoadControl.set_view_model(nextViewModel)
	map.draw_actors()
	var wa = DataManager.get_war_actor(se.fromId)
	if wa == null:
		FlowManager.add_flow("player_skill_end_trigger")
		return
	# 默认由计策发起者汇报
	var speaker = wa
	# 若计策发起者为 AI，由其目标（玩家）汇报
	if speaker.get_controlNo() < 0:
		speaker = DataManager.get_war_actor(se.targetId)
	if speaker == null:
		FlowManager.add_flow("player_skill_end_trigger")
		return
	if startingMessage != "":
		DataManager.set_env("对话PENDING", se.get_report_message(speaker, wa))
		# 在这里汇报到日志
		# 技能调用时应该不至于因为 report 过早而丢信息，但待确认
		# SE-TODO
		se.report()
		# 不适用 play_dialog，尽可能维持计策范围显示
		SceneManager.show_confirm_dialog(startingMessage, wa.actorId, startingMood)
		LoadControl.set_view_model(nextViewModel)
		return
	var msgs = DataManager.get_env_array("对话PENDING")
	DataManager.unset_env("对话PENDING")
	if msgs.empty():
		# 初始化汇报内容
		msgs = Array(se.get_report_message(speaker, wa))
		# 在这里汇报到日志
		# 技能调用时应该不至于因为 report 过早而丢信息，但待确认
		# SE-TODO
		se.report()
	if msgs.size() > 3:
		# 对话过长，拆分出一部分，其余分屏汇报
		DataManager.set_env("对话PENDING", msgs.slice(3, msgs.size()-1))
		msgs = msgs.slice(0, 2)
	# 不适用 play_dialog，尽可能维持计策范围显示
	SceneManager.show_confirm_dialog("\n".join(msgs), speaker.actorId, se.reporter_mood)
	LoadControl.set_view_model(nextViewModel)
	return

# 设置计策增减体力伤害倍率，只可用于 20025 计算计策伤害的回调场合
# @param actorId 来源武将
# @param skill 来源技能
# @param rate 增减百分比
func change_scheme_hp_damage_rate(actorId:int, skill:String, rate:int)->bool:
	var se = DataManager.get_current_stratagem_execution()
	if rate == 0:
		return false
	var baseDamage = DataManager.get_env_int("计策.ONCE.减体")
	if baseDamage <= 0:
		return false
	var damage = DataManager.get_env_int("计策.ONCE.减体")
	if rate == -100:
		damage = 0
	else:
		damage = damage + int(baseDamage * rate / 100)
	DataManager.set_env("计策.ONCE.减体", damage)
	var type = "体力增伤"
	if rate < 0:
		type = "体力减伤"
	if rate == -100:
		type = "体力免伤"
	var msg = "【{0}】{1}{2}%".format([
		skill, type, abs(rate),
	])
	if se.get_action_id(actorId) != actorId:
		msg = ActorHelper.actor(actorId).get_name() + msg
	# 改变比例的信息，一般来说只汇报一次
	se.append_result(skill, msg, rate, actorId, true)
	return true

# 设置计策成功率变化，只可用于 20017 计算命中率的回调场合
# @param actorId 来源武将
# @param skill 来源技能
# @param val 增减百分比数字
func change_scheme_chance(actorId:int, skill:String, val:int)->void:
	if val == 0:
		return
	var prev = get_env_int("计策.ONCE.附加智力")
	set_env("计策.ONCE.附加智力", prev + val)
	var type = "提高"
	if val < 0:
		type = "降低"
	var msg = "【{0}】{1}计策命中率{2}点".format([
		skill, type, abs(val)
	])
	# 以 skill 为单位，不重复汇报
	# 因为 get_rate 会被调用多次
	# 命中率效果没必要重复汇报
	var se = DataManager.get_current_stratagem_execution()
	se.append_message_once(msg, skill)
	return

# 设置计策最终成功率的百分比变化，只可用于 20017 计算命中率的回调场合
# @param actorId 来源武将
# @param skill 来源技能
# @param val 增减百分比比例
func change_scheme_chance_rate(actorId:int, skill:String, val:int)->void:
	if val == 0:
		return
	var rate = get_env_int("计策.ONCE.模拟概率")
	rate = int(rate * (100 + val) / 100)
	set_env("计策.ONCE.限定概率", rate)
	var type = "提高"
	if val < 0:
		type = "降低"
	var se = DataManager.get_current_stratagem_execution()
	var msg = "{0}【{1}】{2}计策命中率{3}%".format([
		se._actor_info(self.actorId), skill, type, abs(val)
	])
	# 以 skill 为单位，不重复汇报
	# 因为 get_rate 会被调用多次
	# 命中率效果没必要重复汇报
	se.append_message_once(msg, skill)
	return

# 解除定止，一般为 DialogInfo 的技能回调
# 参见【河守】等技能
# 不触发事件
func freedom()->bool:
	me = DataManager.get_war_actor(actorId)
	if me == null or me.disabled:
		return false
	me.set_buff("定止", 0, -1, "", true)
	FlowManager.add_flow("draw_actors")
	return false

# 寻找战场技能
func get_valuable_skill_list(targetId:int)->PoolStringArray:
	var ret = []
	var wa = DataManager.get_war_actor(targetId)
	if wa == null:
		return ret
	for skill in SkillHelper.get_actor_war_skills(targetId):
		if skill["主动"] and skill["可用"]:
			ret.insert(0, skill["名称"])
		else:
			ret.append(skill["名称"])
	for skill in SkillHelper.get_actor_skill_names(targetId, 30000):
		if not skill in ret:
			ret.append(skill)
	for skill in SkillHelper.get_actor_skill_names(targetId, 40000):
		if not skill in ret:
			ret.append(skill)
	return ret

func bind_menu_items(items:PoolStringArray, values:Array, columns:int=2)->void:
	set_env("列表值", values)
	SceneManager.lsc_menu_top.set_lsc(Vector2.ZERO, Vector2(270, 40))
	SceneManager.lsc_menu_top.lsc.columns = columns
	SceneManager.lsc_menu_top.lsc.items = items
	SceneManager.lsc_menu_top.lsc._set_data(30)
	SceneManager.lsc_menu_top.show()
	SceneManager.lsc_menu_top.lsc.cursor_index = 0
	return

# 大战场插入对话
func append_free_dialog(wa:War_Actor, msg:String, mood:int, attachTo:War_Actor=null)->War_Character.DialogInfo:
	if attachTo == null:
		attachTo = wa
	var d = War_Character.DialogInfo.new()
	d.actorId = wa.actorId
	d.text = msg
	d.mood = mood
	d.sceneId = 20000
	attachTo.add_dialog_info(d)
	return d

func start_scheme(schemeName:String)->void:
	var se = DataManager.new_stratagem_execution(actorId, schemeName, ske.skill_name)
	se.skip_redo = 1
	se.goback_disabled = 1
	if ske.will_auto_finish_turn():
		se.mark_auto_finish_turn()
	SkillHelper.remove_all_skill_trigger()
	LoadControl.load_script("res://resource/sgz_script/war/player_stratagem.gd")
	map.show_scheme_selector()
	if se.is_area_targeting():
		FlowManager.add_flow("stratagem_choose_area")
	else:
		FlowManager.add_flow("stratagem_choose_actor")
	return

# 判断技能选区时，返回所有选区中心
# 默认是发动者本人
# 可以支持加入其他人的选区，参见柔克等技能
func get_skill_centers(me:War_Actor, ignoreExtra:bool=false)->PoolVector2Array:
	DataManager.set_env("额外技能选区", [])
	var ret = []
	if me == null:
		return ret
	ret.append(me.position)
	# 检查柔克等技能的额外选区光环
	if ignoreExtra:
		return ret
	var extraCenters = DataManager.get_env_array("额外技能选区")
	for buff in SkillRangeBuff.find_for_war_vstate("扩展技能选区", me.wvId):
		var wa = DataManager.get_war_actor(buff.actorId)
		if wa == null or wa.disabled or not wa.has_position():
			continue
		extraCenters.append({"x": wa.position.x, "y": wa.position.y})
		ret.append(wa.position)
	DataManager.set_env("额外技能选区", extraCenters)
	return ret

# 默认的 2888 view model，确认对话并结束主动技，显示技能范围
func on_view_model_2888()->void:
	if me != null and map != null:
		map.draw_outline_by_range(me.position, get_choose_distance())
	wait_for_skill_result_confirmation()
	return

# 默认的 2990 view model，确认对话并结束被动技
func on_view_model_2990()->void:
	wait_for_skill_result_confirmation("")
	return

# 默认的 2999 view model，确认对话并结束主动技
func on_view_model_2999()->void:
	wait_for_skill_result_confirmation()
	return

func cancel_attack() -> void:
	var st = SkillHelper.get_current_skill_trigger()
	if st != null:
		st.next_flow = "attack_cancelled"
	map.draw_actors()
	bf.skip_execution(actorId, ske.skill_name)
	return
