extends "war_base.gd"

const view_model_name = "战争-玩家-步骤";

var istory

var iembattle

func get_view_model()->int:
	return DataManager.get_env_int(view_model_name)

func set_view_model(view_model:int)->void:
	DataManager.set_env(view_model_name, view_model)
	return

func _init() -> void:
	istory = Global.load_script(DataManager.mod_path+"sgz_script/story/IStory.gd")
	FlowManager.bind_import_flow("player_start", self)
	FlowManager.bind_import_flow("player_embattle_actors", self)
	FlowManager.bind_import_flow("player_auto_embattle", self)
	FlowManager.bind_import_flow("player_auto_embattle_check", self)
	FlowManager.bind_import_flow("player_auto_embattle_done", self)
	FlowManager.bind_import_flow("player_before_ready", self)
	FlowManager.bind_import_flow("player_ready", self)
	FlowManager.bind_import_flow("_player_ready", self)
	FlowManager.bind_import_flow("player_end", self)
	FlowManager.bind_import_flow("actor_info", self)
	FlowManager.bind_import_flow("actor_control_menu", self)
	FlowManager.bind_import_flow("player_war_end_confirm", self)
	FlowManager.bind_import_flow("story_dialogs", self)
	FlowManager.bind_signal_method("war_status", self)
	FlowManager.bind_signal_method("war_status_close", self)
	FlowManager.bind_signal_method("war_log", self)
	FlowManager.bind_signal_method("war_log_close", self)
	FlowManager.bind_import_flow("war_jump_effect", self)
	FlowManager.bind_import_flow("player_skill_end_trigger", self)
	FlowManager.bind_import_flow("player_turn_dialog", self)
	FlowManager.bind_import_flow("player_leave_confirmed", self)
	FlowManager.bind_import_flow("player_leave_cancel", self)

	FlowManager.bind_import_flow("player_delegate", self)
	FlowManager.bind_import_flow("player_delegate_confirmed", self)

	FlowManager.bind_import_flow("player_mercy", self)
	FlowManager.bind_import_flow("player_mercy_confirmed", self)

	FlowManager.bind_import_flow("player_yijing", self)
	FlowManager.bind_import_flow("player_yijing_select", self)
	FlowManager.bind_import_flow("player_yijing_selected", self)

	iembattle = Global.load_script(DataManager.mod_path+"sgz_script/war/IEmbattle.gd")
	return
	
func _process(delta: float) -> void:
	if AutoLoad.playerNo != FlowManager.controlNo:
		return
	_input_key(delta)
	return

func _input_key(delta: float):
	var vm = get_view_model()
	var method = "on_view_model_{0}".format([vm])
	if has_method(method):
		SceneManager.update_runtime_info({"vm": vm})
		call(method, delta)
	else:
		# 观战模式下，允许退出
		if DataManager.is_autoplay_mode() and Input.is_action_pressed("EMU_START"):
			var prev = SceneManager.actor_dialog.rtlMessage.text
			DataManager.set_env("观战对话", prev)
			SceneManager.show_yn_dialog("是否结束观战？", -5)
			set_view_model(999)
	return

func on_view_model_0(delta: float):
	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	set_view_model(-1)
	FlowManager.add_flow("player_ready")
	return

func on_view_model_1(delta: float):
	#布阵前对话确认
	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	set_view_model(-1)
	FlowManager.add_flow("player_embattle_actors")
	return

func on_view_model_2(delta: float):
	#布阵
	var map = SceneManager.current_scene().war_map
	var current = DataManager.get_env_int("战争.当前布阵武将")
	var wa = DataManager.get_war_actor(current)
	if current < 0 or wa == null:
		set_view_model(-1)
		FlowManager.add_flow("player_start")
		return

	var wf = DataManager.get_current_war_fight()
	var wv = wa.war_vstate()

	# 显示布阵范围
	var rects = []
	for r in iembattle.get_embattle_all_area(wv):
		r.size = r.size - r.position + Vector2(1, 1)
		rects.append(r)
	map.draw_outline_by_rects(rects)

	# 显示其他已布阵武将
	var existedIds = []
	for existed in wv.get_war_actors(false, true):
		existedIds.append(existed.actorId)
	existedIds.erase(current)
	map.show_can_choose_actors(existedIds)

	# 可以自动布阵
	if wf.date == 1 and Input.is_action_just_pressed("EMU_START"):
		set_view_model(-1)
		FlowManager.add_flow("player_auto_embattle")
		return

	# 在可布阵范围内自由移动
	var dir = Vector2.ZERO
	if Input.is_action_just_pressed("ANALOG_UP"):
		dir = Vector2.UP
	if Input.is_action_just_pressed("ANALOG_DOWN"):
		dir = Vector2.DOWN
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		dir = Vector2.LEFT
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		dir = Vector2.RIGHT
	if dir != Vector2.ZERO:
		if not iembattle.check_actor_location_is_in_area(current, wa.position):
			iembattle.reset_actor_location(current, dir)
		else:
			var newPosition = wa.position + dir
			if not iembattle.check_actor_location_is_in_area(current, newPosition):
				iembattle.reset_actor_location(current, dir)
			else:
				wa.move(newPosition, true, wa.side()=="防守方", true)

	if not Global.is_action_pressed_AX():
		return
	# 按 A 确认位置
	var waitActors = DataManager.get_env_int_array("待布阵武将")
	for teammate in wa.get_teammates(false, true):
		if teammate.position == wa.position:
			# 当前位置有队友，坐下去，让队友站起来
			set_view_model(-1)
			map.touch_war_actor_rect(teammate)
			waitActors.erase(wa.actorId)
			waitActors.erase(teammate.actorId)
			waitActors.append(teammate.actorId)
			DataManager.set_env("待布阵武将", waitActors)
			DataManager.set_env("战争.当前布阵武将", teammate.actorId)
			FlowManager.add_flow("player_embattle_actors")
			return

	if not wa.can_move_to_position(wa.position):
		# 不能进入此地，按了白按
		return

	# 可以布阵的空地，坐下来
	set_view_model(-1)
	waitActors.erase(current)
	DataManager.set_env("待布阵武将", waitActors)
	map.next_shrink_actors.clear()
	if waitActors.empty():
		map.show_color_block_by_position([])
		FlowManager.add_flow("check_embattle")
	else:
		SceneManager.hide_all_tool()
		DataManager.set_env("战争.当前布阵武将", waitActors[0])
		FlowManager.add_flow("player_embattle_actors")
	return

#选择武将 
func on_view_model_3(delta: float):
	var map = SceneManager.current_scene().war_map
	var wf = DataManager.get_current_war_fight()
	var wv = wf.current_war_vstate()
	var currentActorId = -1
	var current = DataManager.get_war_actor_by_position(map.cursor_position)
	if current != null and not current.disabled:
		currentActorId = current.actorId
	if Input.is_action_just_pressed("EMU_START"):
		map.show_actors_ap(false)
		var actorIds = []
		var next = null
		var warActors = wv.get_war_actors(false, true)
		if current != null:
			warActors = current.war_vstate().get_war_actors(false, true)
		for wa in warActors:
			actorIds.append(wa.actorId)
			if next == null:
				next = wa
		if actorIds.has(currentActorId):
			var currentIdx = actorIds.find(currentActorId)
			next = DataManager.get_war_actor(actorIds[(currentIdx + 1) % actorIds.size()])
		if next != null:
			SceneManager.hide_all_tool()
			map.set_cursor_location(next.position, true)
			map.fix_cursor_camer()
			DataManager.player_choose_actor = next.actorId
			DataManager.set_env("武将", next.actorId)
			FlowManager.add_flow("actor_info")
			return
	if Input.is_action_just_pressed("EMU_SELECT"):
		FlowManager.add_flow("war_status")
		return
	if Global.is_action_pressed_Up():
		map.cursor_move_up()
	if Global.is_action_pressed_Down():
		map.cursor_move_down()
	if Global.is_action_pressed_Left():
		map.cursor_move_left()
	if Global.is_action_pressed_Right():
		map.cursor_move_right()
	if Global.is_action_pressed_BY():
		var wa = DataManager.get_war_actor_by_position(map.cursor_position);
		if wa == null or wa.disabled:
			map.show_actors_ap(not map.actors_ap)
			return
		map.show_actors_ap(false)
		DataManager.set_env("武将", wa.actorId)
		FlowManager.add_flow("actor_info")
		return
	if not Global.is_action_pressed_AX():
		return
	if current == null or current.disabled:
		return
	map.show_actors_ap(false)
	var actor_controlNo = DataManager.get_actor_controlNo(currentActorId)
	if not actor_controlNo in [-1,FlowManager.controlNo]:
		return
	if wv.id != current.wvId:
		return
	if actor_controlNo==-1 && FlowManager.controlNo != wv.get_main_controlNo():
		return
	DataManager.player_choose_actor = currentActorId
	FlowManager.add_flow("actor_control_menu")
	return

func on_view_model_4(delta: float):
	#控制菜单
	if Input.is_action_just_pressed("ANALOG_UP"):
		SceneManager.lsc_menu.lsc.move_up()
	if Input.is_action_just_pressed("ANALOG_DOWN"):
		SceneManager.lsc_menu.lsc.move_down()
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		SceneManager.lsc_menu.lsc.move_left()
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		SceneManager.lsc_menu.lsc.move_right()
	if Global.is_action_pressed_BY():
		if not SceneManager.lsc_menu.is_msg_complete():
			return
		set_view_model(-1)
		FlowManager.add_flow("player_ready")
		return
	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.lsc_menu.is_msg_complete():
		SceneManager.lsc_menu.show_all_msg()
		return
	var menu_array = DataManager.get_env_array("列表值")
	var choose_value = str(menu_array[SceneManager.lsc_menu.lsc.cursor_index]);
	_menu_go(choose_value)
	return

func on_view_model_6(delta: float):
	#查看武将信息、状态
	var wf = DataManager.get_current_war_fight()
	var wv = wf.current_war_vstate()
	var map = SceneManager.current_scene().war_map
	var conEquipInfo:Control = SceneManager.conEquipInfo;
	var currentId = SceneManager.actor_info.get_current_actorId()
	var current = DataManager.get_war_actor(currentId)
	conEquipInfo.show_war_status(current)
	conEquipInfo.show()
	if Global.is_action_pressed_BY():
		FlowManager.add_flow("_player_ready")
		return
	if Global.is_action_pressed_AX():
		if current.wvId == wv.id:
			DataManager.player_choose_actor = currentId
			FlowManager.add_flow("actor_control_menu")
		return
	if not Input.is_action_just_pressed("EMU_START"):
		return
	var next = null
	var last = null
	for wa in current.war_vstate().get_war_actors(false, true):
		if next == null:
			next = wa
		if last != null and last.actorId == current.actorId:
			next = wa
			break
		last = wa
	if next == null:
		next = current.get_leader()
	if next == null:
		return
	SceneManager.hide_all_tool()
	map.set_cursor_location(next.position, true)
	map.fix_cursor_camer()
	DataManager.player_choose_actor = next.actorId
	DataManager.set_env("武将", next.actorId)
	FlowManager.add_flow("actor_info")
	return

func on_view_model_7(delta: float):
	#确认后进入结算界面
	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	set_view_model(-1)
	SceneManager.hide_all_tool()
	FlowManager.add_flow("war_over_start")
	return

func on_view_model_9(delta: float):
	#剧情模式确认对白
	var map = SceneManager.current_scene().war_map
	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	set_view_model(-1)
	map.next_shrink_actors = [];
	var type = DataManager.get_env_str("剧情.对白类型")
	if not istory.get_story_dialog(type, false).empty():
		FlowManager.add_flow("story_dialogs")
		return
	set_view_model(-1)
	match type:
		"回合内":
			FlowManager.add_flow("player_ready")
		"胜利":
			var no = DataManager.get_env_int("剧情.关卡")
			var vstateId = DataManager.get_env_int("剧情.势力")
			if istory.load_story(vstateId, no+1):
				return
			SceneManager.restart()
		"失败":
			SceneManager.restart()
	return

func on_view_model_10(delta: float):
	#确认插入对话
	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	set_view_model(-1)
	var nextFlow = DataManager.get_env_str("战争.玩家.等待对话流程")
	if nextFlow == "":
		nextFlow = "player_ready"
	FlowManager.add_flow(nextFlow)
	return

func on_view_model_11(delta: float):
	#额外回合结束
	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	set_view_model(-1)
	FlowManager.add_flow("player_end")
	return

func on_view_model_12(delta: float):
	#跃马效果期间
	var map = SceneManager.current_scene().war_map
	var current = map.cursor_position
	var posInfos = DataManager.get_env_array("战争.跃马可选位置")
	var positions = []
	for posInfo in posInfos:
		var v = Vector2(int(posInfo["x"]), int(posInfo["y"]))
		positions.append(v)
	var idx = positions.find(current)
	if idx < 0:
		idx = 0
		current = positions[0]
		map.set_cursor_location(current, true)
	if Input.is_action_just_pressed("ANALOG_UP"):
		idx = ActorHelper.find_next_war_position(positions, idx, Vector2.UP)
	if Input.is_action_just_pressed("ANALOG_DOWN"):
		idx = ActorHelper.find_next_war_position(positions, idx, Vector2.DOWN)
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		idx = ActorHelper.find_next_war_position(positions, idx, Vector2.LEFT)
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		idx = ActorHelper.find_next_war_position(positions, idx, Vector2.RIGHT)
	if idx < 0:
		idx = 0
	current = positions[idx]
	map.set_cursor_location(current, true)
	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	set_view_model(-1)
	var actorId = DataManager.get_env_int("战争.跃马武将")
	var actor = ActorHelper.actor(actorId)
	var wa = DataManager.get_war_actor(actorId)
	wa.position = map.cursor_position
	map.set_cursor_location(wa.position)
	map.cursor.show()
	DataManager.unset_env("战争.跃马武将")
	DataManager.unset_env("战争.跃马可选位置")
	var msg = "{0}真神马也!";
	if actor.actorId == StaticManager.ACTOR_ID_LIUBEI:
		msg = "{0}!{0}!岂能妨主!";
	LoadControl._error(msg.format([actor.get_steed().name()]),actorId,1)
	return

func on_view_model_20(delta: float):
	#战争状态菜单
	if Input.is_action_just_pressed("EMU_START"):
		set_view_model(-1)
		FlowManager.add_flow("war_log")
		return
	if Global.is_action_pressed_BY() or Input.is_action_just_pressed("EMU_SELECT"):
		if not SceneManager.dialog_msg_complete(true):
			return
		set_view_model(-1)
		FlowManager.add_flow("war_status_close")
		return
	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	set_view_model(-1)
	FlowManager.add_flow("war_log")
	return

func on_view_model_21(delta: float):
	#战争技能日志
	if Global.is_action_pressed_BY() or Input.is_action_just_pressed("EMU_SELECT"):
		if not SceneManager.dialog_msg_complete(true):
			return
		set_view_model(-1)
		FlowManager.add_flow("war_log_close")
		return
	var war_log = SceneManager.current_scene().get_node_or_null("war_log")
	if war_log == null:
		return
	if Global.is_action_pressed_Left():
		war_log.scroll_page_up()
	if Global.is_action_pressed_Right():
		war_log.scroll_page_down()
	if Global.is_action_pressed_Up():
		war_log.scroll_up()
	if Global.is_action_pressed_Down():
		war_log.scroll_down()
	return

func on_view_model_30(delta: float):
	#自动布阵完成
	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	set_view_model(-1)
	FlowManager.add_flow("player_auto_embattle_check")
	return

func on_view_model_31(delta: float):
	var wf = DataManager.get_current_war_fight()
	var wvId = DataManager.get_env_int("布阵方")
	var wv = wf.get_war_vstate(wvId)
	var map = SceneManager.current_scene().war_map
	map.cursor.show()

	var waitActors = DataManager.get_env_int_array("待布阵武将")
	var current = DataManager.get_env_int("布阵.调整武将")

	# 显示布阵范围
	var rects = []
	for r in iembattle.get_embattle_all_area(wv):
		r.size = r.size - r.position + Vector2(1, 1)
		rects.append(r)
	map.draw_outline_by_rects(rects)

	# 显示其他已布阵武将
	var existedIds = []
	for existed in wv.get_war_actors(false, true):
		existedIds.append(existed.actorId)
	existedIds.erase(current)
	map.show_can_choose_actors(existedIds)

	var wa = null
	if current >= 0:
		wa = DataManager.get_war_actor(current)
		if wa.wvId != wvId:
			wa = null

	if wa == null:
		# 未选择调整武将，自由移动光标
		if Global.is_action_pressed_Up():
			map.cursor_move_up()
		if Global.is_action_pressed_Down():
			map.cursor_move_down()
		if Global.is_action_pressed_Left():
			map.cursor_move_left()
		if Global.is_action_pressed_Right():
			map.cursor_move_right()
		if Input.is_action_just_pressed("EMU_START"):
			set_view_model(-1)
			FlowManager.add_flow("player_auto_embattle_done")
			return
		if not Global.is_action_pressed_AX():
			return
		wa = DataManager.get_war_actor_by_position(map.cursor_position)
		if wa == null or wa.disabled or wa.wvId != wvId:
			return
		DataManager.set_env("布阵.调整武将", wa.actorId)
		return

	# 已选择调整武将，在允许布阵范围内自由移动
	SceneManager.show_actor_info(wa.actorId)
	map.cursor.hide()
	map.next_shrink_actors = [wa.actorId]
	var dir = Vector2.ZERO
	if Input.is_action_just_pressed("ANALOG_UP"):
		dir = Vector2.UP
	if Input.is_action_just_pressed("ANALOG_DOWN"):
		dir = Vector2.DOWN
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		dir = Vector2.LEFT
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		dir = Vector2.RIGHT
	if dir != Vector2.ZERO:
		if not iembattle.check_actor_location_is_in_area(wa.actorId, wa.position):
			iembattle.reset_actor_location(wa.actorId, dir)
		else:
			var newPosition = wa.position + dir
			if not iembattle.check_actor_location_is_in_area(wa.actorId, newPosition):
				iembattle.reset_actor_location(wa.actorId, dir)
			else:
				wa.move(newPosition, true, wa.side()=="防守方", true)

	if not Global.is_action_pressed_AX():
		return

	# 按下A
	for teammate in wa.get_teammates(false, true):
		if teammate.position == wa.position:
			# 当前位置有队友，坐下来，让队友站起来
			map.touch_war_actor_rect(teammate)
			DataManager.set_env("布阵.调整武将", teammate.actorId)
			return

	# 当前位置不能坐
	if not wa.can_move_to_position(wa.position):
		return

	# 坐下来
	map.next_shrink_actors.clear()
	DataManager.set_env("布阵.调整武将", -1)
	return

func on_view_model_40(delta: float):
	Global.wait_for_yesno("player_mercy_confirmed", "back_to_war_clear_trigger", view_model_name)
	return

func on_view_model_50(delta: float):
	Global.wait_for_confirmation("player_yijing_select", view_model_name)
	return

func on_view_model_51(delta: float):
	var actorId = DataManager.player_choose_actor
	var menu = SceneManager.lsc_menu_top
	var lsc = menu.lsc
	var selected = get_yijing_selected_skills(actorId)

	# 预设的时候设置 set_selected_by_array 不好使
	# 只好在这里再设一遍
	var selectedIndexes = []
	for skill in selected:
		var idx = menu.lsc.items.find(skill)
		if idx >= 0:
			selectedIndexes.append(idx)
	menu.lsc.set_selected_by_array(selectedIndexes)

	var limit = min(4, lsc.items.size())
	if Global.is_action_pressed_BY() \
		and SceneManager.dialog_msg_complete():
		if lsc.get_selected_list().size() != limit:
			var msg = "须选择 {1} 个技能（{0}/{1}）\n「A」键选择".format([
				lsc.get_selected_list().size(), limit
			])
			SceneManager.actor_dialog.rtlMessage.text = msg
			return
		set_view_model(-1)
		FlowManager.add_flow("player_yijing_selected")
		return
	if not Global.wait_for_choose_skill("", ""):
		return
	var skill = DataManager.get_env_str("目标项")
	var idx = lsc.items.find(skill)
	if idx < 0:
		return
	if skill in selected:
		selected.erase(skill)
	else:
		selected.append(skill)
	set_yijing_selected_skills(actorId, selected)
	selected = get_yijing_selected_skills(actorId)
	var msg = "选择「道」面技能（{0}/{1}）\n「A」键选择".format([
		selected.size(), limit
	])
	if selected.size() == limit:
		msg = "选择「道」面技能（{0}/{1}）\n「B」键确认".format([
			limit, limit
		])
	SceneManager.actor_dialog.rtlMessage.text = msg
	return

func on_view_model_52(delta: float):
	Global.wait_for_confirmation("check_embattle_trigger", view_model_name)
	return

func on_view_model_886(delta: float):
	Global.wait_for_yesno("player_delegate_confirmed", "player_ready", view_model_name)
	return

func on_view_model_999(delta: float):
	wait_for_yesno("player_leave_confirmed", "player_leave_cancel")
	return

func player_leave_confirmed():
	set_view_model(-1)
	LoadControl.end_script()
	# 重要，防守方武将必须归位，否则武将会消失
	var wf = DataManager.get_current_war_fight()
	wf.defenderWV.send_all_actors_to_city(wf.target_city())
	# 进攻方暂时不用归位，因为有「派遣武将」环境变量
	# 但是如果发生了俘虏，会有些冲突，但可以接受
	# FIXME later
	#wf.attackerWV.send_all_actors_to_city(wf.from_city())
	FlowManager.add_flow("go_to_scene|res://scene/scene_affiars/scene_affiars.tscn")
	FlowManager.add_flow("load_script|affiars/auto_events/AI/think_war.gd")
	FlowManager.add_flow("AI_War_3_AI")
	return

func player_leave_cancel():
	set_view_model(-1)
	var prev = DataManager.get_env_str("观战对话")
	if prev != "":
		SceneManager.show_confirm_dialog(prev)
	return

func _menu_go(choose_value:String):
	match choose_value:
		"移动":
			FlowManager.add_flow("load_script|war/player_move.gd");
			FlowManager.add_flow("actor_move_start");
		"攻击":
			FlowManager.add_flow("load_script|war/player_attack.gd");
			FlowManager.add_flow("attack_start");
		"计策":
			FlowManager.add_flow("load_script|war/player_stratagem_menu.gd");
			FlowManager.add_flow("stratagem_menu");
		"待机":
			FlowManager.add_flow("load_script|war/player_sleep.gd");
			FlowManager.add_flow("sleep_start");
		"撤退":
			var wa = DataManager.get_war_actor(DataManager.player_choose_actor)
			if wa.get_buff_label_turn(["围困"]) > 0:
				LoadControl._error("处于围困状态\n无法撤退", DataManager.player_choose_actor)
				return
			FlowManager.add_flow("load_script|war/player_retreat.gd");
			FlowManager.add_flow("retreat_start");
		"技能":
			FlowManager.add_flow("load_script|war/player_skill_menu.gd");
			FlowManager.add_flow("skill_menu_start");
		"营帐":
			DataManager.set_env("列表页码", 0)
			FlowManager.add_flow("load_script|war/player_camp.gd")
			FlowManager.add_flow("player_camp_start_list")
		"回营":
			FlowManager.add_flow("load_script|war/player_camp.gd")
			FlowManager.add_flow("player_camp_in_start")
		"物品":
			FlowManager.add_flow("load_script|war/player_item.gd")
			FlowManager.add_flow("player_item_start")
		"托管":
			FlowManager.add_flow("player_delegate")
	return

#战争开始
func player_start():
	if FlowManager.controlNo != AutoLoad.playerNo:
		return
	var wvId = DataManager.get_env_int("布阵方")
	var wf = DataManager.get_current_war_fight()
	var wv = wf.get_war_vstate(wvId)
	var map = SceneManager.current_scene().war_map
	map.cursor.hide()
	
	var waitActors = []
	for wa in wv.get_war_actors(false):
		#寻找未布阵的武将
		if wa.has_position() or wa.get_ext_variable("跳过布阵", 0) == 1:
			continue
		waitActors.append(wa.actorId)
	if waitActors.empty():
		map.show_color_block_by_position([])
		FlowManager.add_flow("check_embattle")
		return
	#显示第一个
	DataManager.set_env("战争.当前布阵武将", waitActors[0])
	DataManager.set_env("待布阵武将", waitActors)
	var msg = "{0}大人\n安置武将于何处？\n请指定地点".format([wv.get_leader().get_name()])
	SceneManager.show_confirm_dialog(msg)
	set_view_model(1)
	return

#自动布阵
func player_auto_embattle():
	var wf = DataManager.get_current_war_fight()
	var wvId = DataManager.get_env_int("布阵方")
	var wv = wf.get_war_vstate(wvId)
	var actors = DataManager.get_env_int_array("待布阵武将")
	if actors.empty():
		FlowManager.add_flow("check_embattle")
		return
	var candidates = []
	for actorId in actors:
		var wa = DataManager.get_war_actor(actorId)
		if wa == null or wa.disabled:
			continue
		candidates.append(wa)
	# 尝试使用历史自动布阵数据
	
	if wv.side == "防守方":
		var direction = wf.warDirection
		var positions = Array(wf.target_city().get_auto_embattle_positions(direction))
		var unsettled = []
		while not candidates.empty() and not positions.empty():
			var wa = candidates.pop_front()
			var pos = positions.pop_front()
			if wa.can_move_to_position(pos):
				wa.position = pos
			else:
				unsettled.append(wa)
		candidates.append_array(unsettled)
	if candidates.size() > 1:
		var leader = candidates.pop_front()
		# 主将不变，其他人按战斗力排序
		candidates.sort_custom(Global.actorComp, "by_power")
		candidates.insert(0, leader)
	for wa in candidates:
		if not wa.has_position():
			iembattle.set_default_actor_embattle(wa);
	FlowManager.add_flow("draw_actors")
	var msg = "已自动布阵\n可选择武将调整位置"
	DataManager.set_env("战争.当前布阵武将", actors[0])
	SceneManager.show_confirm_dialog(msg)
	set_view_model(30)
	return

#自动布阵后的调整
func player_auto_embattle_check()->void:
	var waitActors = DataManager.get_env_int_array("待布阵武将")
	if waitActors.empty():
		FlowManager.add_flow("check_embattle")
		return
	SceneManager.hide_all_tool()
	SceneManager.show_unconfirm_dialog("可选择武将调整位置\n「开始」键结束布阵")
	var map = SceneManager.current_scene().war_map
	map.cursor_position = DataManager.get_war_actor(waitActors[0]).position
	map.camer_to_actorId(waitActors[0], "")
	map.next_shrink_actors = []
	set_view_model(31)
	return

func player_auto_embattle_done()->void:
	var wf = DataManager.get_current_war_fight()
	# 若为防守方，记忆当前布阵位置
	var wvId = DataManager.get_env_int("布阵方")
	var wv = wf.get_war_vstate(wvId)
	if wv.side == "防守方":
		var direction = wf.warDirection
		var positions = []
		for wa in wv.get_war_actors(false, true):
			positions.append(wa.position)
		wf.target_city().set_auto_embattle_positions(direction, positions)
	var map = SceneManager.current_scene().war_map
	DataManager.unset_env("布阵.调整武将")
	map.clear_can_choose_actors()
	map.cursor.hide()
	FlowManager.add_flow("check_embattle")
	return

#布阵
func player_embattle_actors():
	var map = SceneManager.current_scene().war_map
	var current = DataManager.get_env_int("战争.当前布阵武将")
	var wa = DataManager.get_war_actor(current)
	if current < 0 or wa == null:
		FlowManager.add_flow("player_start")
		return
	map.next_shrink_actors = [current]

	var waitActors = DataManager.get_env_int_array("待布阵武将")
	
	iembattle.set_default_actor_embattle(wa)
	map.touch_war_actor_rect(wa)
	map.camer_to_actorId(wa.actorId, "")
	SceneManager.show_actor_info(wa.actorId)
	FlowManager.add_flow("draw_actors")
	set_view_model(2)
	return

#回合初始
func player_before_ready():
	set_view_model(-1)
	DataManager.set_env("战争-AI-步骤", -1)

	#默认选中人物=当前可控优先级最大的人物（显示对应人的机动力）
	var default_actor = _defaut_war_actor(FlowManager.controlNo);
	if default_actor == null or default_actor.disabled:
		FlowManager.add_flow("turn_control_end");
		return;
	DataManager.player_choose_actor = default_actor.actorId;

	#根据光标移动镜头位置
	var war_map = SceneManager.current_scene().war_map;
	war_map.camer_to_actorId(default_actor.actorId, "player_ready");
	return

func player_skill_end_trigger():
	var ske = SkillHelper.read_skill_effectinfo()
	DataManager.set_env("战争.完成技能", ske.output_data())
	if SkillHelper.auto_trigger_skill(ske.skill_actorId, 20040, "player_ready"):
		return
	DataManager.unset_env("战争.完成技能")
	FlowManager.add_flow("player_ready")
	return

#回合提示对话
func player_ready():
	# 兼容历史错误数据
	DataManager.set_env("战争-AI-步骤", -1)
	Global.clear_waits()
	SoundManager.play_bgm("", true, true)
	if DataManager.war_control_sort.size() > DataManager.war_control_sort_no and DataManager.war_control_sort[DataManager.war_control_sort_no] < 0:
		LoadControl.end_script()
		FlowManager.add_flow("AI_before_ready")
		return
	LoadControl.view_model_name = view_model_name;
	if DataManager.common_variable.has("战争.跃马武将"):
		FlowManager.add_flow("war_jump_effect");
		return;
	# 不支持 flow，但可以通过闲时对话插入逻辑
	if DataManager.player_choose_actor >= 0:
		SkillHelper.auto_trigger_skill(DataManager.player_choose_actor, 20031, "")
	if not _player_ready():
		return
	var scene_war = SceneManager.current_scene();
	var war_map = scene_war.war_map
	war_map.update_ap(DataManager.player_choose_actor)
	#光标回置
	var wa = DataManager.get_war_actor(DataManager.player_choose_actor);
	if wa != null and not wa.disabled and wa.has_position():
		war_map.set_cursor_location(wa.position)
	else:
		var position = war_map.get_save_cursor_position()
		war_map.set_cursor_location(position)
	war_map.update_cursor_position_at_once()
	return

func _player_ready()->bool:
	LoadControl.end_script()
	#检查是否升级
	_check_actors_levelup()
	#检查剧情对白
	var dialogCondition = "回合内"
	if not istory.get_story_dialog(dialogCondition, false).empty():
		set_view_model(-1)
		DataManager.set_env("剧情.对白类型", dialogCondition)
		FlowManager.add_flow("story_dialogs")
		return false
	#检查普通对白
	if _check_wait_dialog():
		set_view_model(-1)
		FlowManager.add_flow("player_turn_dialog")
		return false
	# 闲时对话检查结束
	# 确认是否有势力战败
	if check_war_vstates_status():
		FlowManager.add_flow("war_vstate_settlement")
		return false
	var wf = DataManager.get_current_war_fight()
	var wv = wf.current_war_vstate()
	if wv.get_main_controlNo() < 0:
		FlowManager.add_flow("AI_before_ready")
		return false
	if wv.lost():
		# 玩家援军失败会走到这里
		FlowManager.add_flow("player_end")
		return false

	var scene_war = SceneManager.current_scene();
	var war_map = scene_war.war_map;
	war_map.next_shrink_actors.clear();
	
	war_map.clear_can_choose_actors();
	war_map.show_color_block_by_position([]);
	war_map.cursor.show()
	var msg = "{0}大人".format([wv.get_leader().get_name()])
	if DataManager.is_extra_war_round():
		if DataManager.is_extra_war_round_over():
			SceneManager.show_unconfirm_dialog("结束额外回合\n观看敌军行动")
			set_view_model(11)
			return false
		msg += "\n当前为额外回合"
		msg += "\n请向{0}下达命令".format([DataManager.get_extra_round_desc()])
		var extraActorIds = DataManager.get_extra_round_actors()
		war_map.show_war_actors_disabled(true, wv.id, extraActorIds)
	elif wv.is_reinforcement():
		msg += "\n目前为援军行动"
		msg += "\n向哪位武将下达命令？"
	else:
		msg += "\n向哪位武将下达命令？"
	DataManager.set_env("指令提示", msg)
	SceneManager.show_unconfirm_dialog(msg)
	set_view_model(3)
	return true

func player_turn_dialog(nextFlow:String="player_ready"):
	var data = DataManager.get_env_dict("战争.玩家.等待对白")
	if data.empty():
		FlowManager.add_flow(nextFlow)
		return
	var d = War_Character.DialogInfo.new()
	d.input(data)
	DataManager.unset_env("战争.玩家.等待对白")
	if d.se != "":
		SoundManager.play_anim_bgm(d.se)
	if d.callback_script != "" and d.callback_method != "":
		var sc = Global.load_script("res://resource/sgz_script/" + d.callback_script)
		if sc.has_method(d.callback_method):
			sc.actorId = d.actorId
			var fromId = DataManager.get_env_int("战争.玩家.等待对白来源")
			if fromId >= 0:
				sc.actorId = fromId
			DataManager.unset_env("战争.玩家.等待对白来源")
			sc.call(d.callback_method)
	var map = SceneManager.current_scene().war_map
	map.camer_to_actorId(d.actorId, "")
	SceneManager.show_confirm_dialog(d.text, d.actorId, d.mood)
	map.next_shrink_actors = [d.actorId]
	DataManager.set_env("战争.玩家.等待对话流程", nextFlow)
	set_view_model(10)
	return

#回合结束
func player_end():
	set_view_model(-1)
	var wf = DataManager.get_current_war_fight()
	var wv = wf.current_war_vstate()
	var war_map = SceneManager.current_scene().war_map
	war_map.cursor.hide()
	war_map.clear_can_choose_actors()
	war_map.show_war_actors_disabled(false, wv.id)
	war_map.next_shrink_actors.clear()
	LoadControl.end_script()
	FlowManager.add_flow("turn_control_end")
	return

#B键查看武将
func actor_info():
	var actorId = DataManager.get_env_int("武将")
	var wa = DataManager.get_war_actor(actorId)
	if wa == null:
		set_view_model(3)
		return
	var map = SceneManager.current_scene().war_map
	map.cursor.hide();
	map.next_shrink_actors = [actorId]
	var actorIds = []
	for teammate in wa.war_vstate().get_war_actors(false, true):
		actorIds.append(teammate.actorId)
	var idx = actorIds.find(actorId)
	if idx < 0:
		actorIds.insert(0, actorId)
	else:
		actorIds = actorIds.slice(idx, actorIds.size()) + actorIds.slice(0, idx)
	SceneManager.show_actor_info_list(actorIds, true, "", false)
	map.update_ap(actorId)
	set_view_model(6)
	return

#武将控制菜单
func actor_control_menu():
	var actorId = DataManager.player_choose_actor
	if DataManager.is_extra_war_round():
		if not actorId in DataManager.get_extra_round_actors():
			SceneManager.show_confirm_dialog("{0}的额外回合\n{1}不可行动".format([
				DataManager.get_extra_round_desc(),
				ActorHelper.actor(actorId).get_name()
			]))
			set_view_model(10)
			return
	var map = SceneManager.current_scene().war_map
	map.update_ap(actorId)
	map.cursor.hide()
	map.next_shrink_actors = [actorId]

	var wa = DataManager.get_war_actor(actorId)
	var wv = wa.war_vstate()
	var menu = ["移动", "攻击", "计策", "待机", "撤退"]
	
	if DataManager.get_game_setting("技能系统") == "是":
		var skills = SkillHelper.get_actor_war_skills(actorId)
		if not skills.empty():
			menu.append("技能")
	
	#军营中有武将，且当前是主将，则添加军营【选项】
	if actorId == wv.main_actorId:
		if not wv.camp_actors.empty():
			menu.append("营帐")
		if not wv.is_reinforcement():
			menu.append("托管")
	else:
		menu.append("回营")

	if DataManager.game_mode2 == 1 || DataManager.endless_model:
		#剧情模式或无尽模式，禁止撤退
		menu.erase("撤退")

	#if DataManager.is_test_player():
	#	menu.append("物品")

	# 兼容人偶逻辑
	if actorId >= StaticManager.ACTOR_ID_RENOU:
		menu.erase("撤退")
		menu.erase("回营")

	DataManager.set_env("列表值", menu)
	SceneManager.lsc_menu.lsc.columns = 2
	SceneManager.lsc_menu.lsc.items = menu
	if menu.size() <= 6:
		SceneManager.lsc_menu.show_msg("请下达命令", Vector2(15,0));
		SceneManager.lsc_menu.set_actor_lsc(actorId, Vector2(25, 0), Vector2(170, 40))
	else:
		SceneManager.lsc_menu.show_msg("", Vector2(15,130))
		SceneManager.lsc_menu.set_actor_lsc(actorId, Vector2(25, -40), Vector2(170, 40))
	SceneManager.lsc_menu.lsc._set_data()
	SceneManager.hide_all_tool()
	SceneManager.lsc_menu.show()
	set_view_model(4)
	return

#当前控制者默认控制的武将（必须是可控的）
func _defaut_war_actor(controlNo:int)->War_Actor:
	#额外回合，第一个额外行动武将
	if DataManager.is_extra_war_round():
		for tmpActorId in DataManager.get_extra_round_actors():
			var tmpWA = DataManager.get_war_actor(tmpActorId)
			if tmpWA == null or tmpWA.disabled:
				continue
			return tmpWA
	var wf = DataManager.get_current_war_fight()
	var wv = wf.current_war_vstate()
	return wv.get_leader()

#战争结束时，对玩家提示
func player_war_end_confirm():
	LoadControl.end_script()
	var player:Player = DataManager.players[FlowManager.controlNo]
	var playerActor = ActorHelper.actor(player.actorId)
	var wf = DataManager.get_current_war_fight()
	# 解除托管状态
	for wv in wf.war_vstates():
		wv.delegate(false)
	var playerWV = wf.defenderWV
	if playerWV.get_main_controlNo() < 0:
		# 多玩家 wv 时可能不 work
		playerWV = wf.attackerWV
	if playerWV == null:
		set_view_model(-1)
		SceneManager.hide_all_tool()
		FlowManager.add_flow("war_over_start")
		return

	var playerLost = playerWV.check_lose()
	var dialogCondition = "失败" if playerLost else "胜利"
	if not istory.get_story_dialog(dialogCondition, false).empty():
		SoundManager.play_bgm("res://resource/sounds/bgm/War_End.ogg")
		DataManager.set_env("剧情.对白类型", dialogCondition)
		FlowManager.add_flow("story_dialogs")
		return

	var reason = playerWV.lose_reason
	var speaker = playerWV.main_actorId
	var mood = 3
	if not playerLost:
		reason = playerWV.get_enemy_vstate().lose_reason
		mood = 1
	
	var msg = ""
	match reason:
		War_Vstate.Lose_ReasonEnum.OverDay:
			if playerLost:
				msg = "{0}大人\n战争持续太久\n不得不暂时退却"
			else:
				msg = "{0}大人\n敌军已开始退却"
				SceneManager.show_confirm_dialog(msg, playerWV.main_actorId, 1)
		War_Vstate.Lose_ReasonEnum.FoodExhaustion:
			if playerLost:
				msg = "{0}大人\n我军粮草不足\n不得不暂时退却"
			else:
				msg = "{0}大人\n敌军粮尽退却"
		War_Vstate.Lose_ReasonEnum.LoseCity:
			if playerLost:
				msg = "大事不好!\n敌军已占领主城！"
			else:
				msg = "可喜可贺!\n我军已占领主城！"
		War_Vstate.Lose_ReasonEnum.MainActorLose:
			if playerLost:
				speaker = -1
				for wa in playerWV.get_war_actors(false):
					speaker = wa.actorId
					break
				msg = "{0}大人\n我军失去主将\n不得不暂时退却"
			else:
				msg = "{0}大人\n敌军失去主将\n已开始退却"
		_:
			set_view_model(-1)
			SceneManager.hide_all_tool()
			FlowManager.add_flow("war_over_start")
			return
	msg = msg.format([playerActor.get_name()])
	SceneManager.show_confirm_dialog(msg, speaker, mood)
	set_view_model(7)
	return

func check_war_vstates_status()->bool:
	var wf = DataManager.get_current_war_fight()
	var somethingHappened = false
	for wv in wf.war_vstates():
		#调用自动检查失败条件程序
		wv.check_lose()
		# 需要结算
		if wv.requires_lost_settlement():
			somethingHappened = true
	# 主要势力失败?
	if wf.defenderWV.lost() or wf.attackerWV.lost():
		somethingHappened = true
	return somethingHappened

#检查武将升级，并插入闲时对话
func _check_actors_levelup():
	var wf = DataManager.get_current_war_fight()
	for wa in wf.get_war_actors(false):
		# 如果升级了，再检查一次
		# 因为可能有连续升级，比如技能【赋诗】的影响
		if _check_actor_levelup(wa):
			_check_actor_levelup(wa)
	return

func _check_actor_levelup(wa:War_Actor)->bool:
	var actor = ActorHelper.actor(wa.actorId)
	var history = actor.get_levelup_trackings()
	if history.empty():
		return false
	var leader = DataManager.get_war_actor(wa.get_main_actor_id())
	if leader == null:
		return false
	for record in actor.get_levelup_trackings():
		var msgs = []
		msgs.append("{0}升至{1}级，体力回满".format([
			actor.get_name(), record["level"],
		]))
		for attr in record["attrs"]:
			var msg = "【{0}】提升至{1}".format([attr, record["attrs"][attr][1]])
			msgs.append(msg)
		for skill in record["skills"]:
			msgs.append("解锁新技能：【{0}】".format([skill]))
		for from in range(0, msgs.size(), 3):
			var to = min(from + 3, msgs.size()) - 1
			var msg = "\n".join(msgs.slice(from, to))
			var d = leader.attach_free_dialog(msg, 1)
			d.se = "res://resource/sounds/se/LevelUp.ogg"
	# 升级体力回满
	# 不放在 actor.check_levelup() 里
	# 避免小战场直接回满了
	actor.set_hp(actor.get_max_hp())
	actor.reset_levelup_trackings()
	# 不支持 flow，可插入闲时对话
	SkillHelper.auto_trigger_skill(actor.actorId, 20033, "")
	return true

#播放剧情文字
func story_dialogs():
	set_view_model(9);
	var scene_war = SceneManager.current_scene();
	var war_map = scene_war.war_map;
	war_map.show_actors_name(true);
	var dic_dialog:Dictionary = istory.get_story_dialog(DataManager.common_variable["剧情.对白类型"],true);
	if(!dic_dialog.has("武将")):
		dic_dialog["武将"]=-1;
	if(!dic_dialog.has("心情")):
		dic_dialog["心情"]=2;
	SceneManager.show_confirm_dialog(dic_dialog["文字"],int(dic_dialog["武将"]),int(dic_dialog["心情"]));
	war_map.next_shrink_actors = [int(dic_dialog["武将"])];

func war_status():
	set_view_model(20)
	var msg = "[B] / [选择]，回到地图"
	if DataManager.get_game_setting("技能系统") == "是":
		msg += "\n[A] / [开始]，查看技能日志"
	SceneManager.show_unconfirm_dialog(msg)
	SceneManager.dialog_msg_complete(true)
	var war_status = SceneManager.current_scene().get_node_or_null("war_status")
	if war_status == null:
		FlowManager.add_flow("war_status_close")
		return
	war_status.update_data()
	war_status.show();
	return

func war_status_close():
	var war_status = SceneManager.current_scene().get_node_or_null("war_status")
	if war_status != null:
		war_status.hide();
	FlowManager.add_flow("_player_ready")
	return

func war_log():
	set_view_model(21)
	var msg = "[B] / [选择]，回到地图\n上下左右移动查看日志"
	SceneManager.show_unconfirm_dialog(msg)
	SceneManager.dialog_msg_complete(true)
	var war_status = SceneManager.current_scene().get_node_or_null("war_status")
	if war_status != null:
		war_status.hide()
	var war_log = SceneManager.current_scene().get_node_or_null("war_log")
	if war_log == null:
		FlowManager.add_flow("war_log_close")
		return
	war_log.update_data();
	war_log.show();
	return

func war_log_close():
	var war_log = SceneManager.current_scene().get_node_or_null("war_log")
	if war_log != null:
		war_log.hide();
	FlowManager.add_flow("_player_ready")
	return

#跃马效果
func war_jump_effect():
	var map = SceneManager.current_scene().war_map
	var actorId = DataManager.get_env_int("战争.跃马武将")
	if actorId < 0:
		LoadControl._error("")
		return
	var wa = DataManager.get_war_actor(actorId)
	if wa == null or wa.get_controlNo() < 0:
		player_ready()
		DataManager.unset_env("战争.跃马武将")
		DataManager.unset_env("战争.跃马可选位置")
		return
	#马走日
	var positions = Array(map.get_horse_jump_positions(wa))
	# 加入当前位置，可以不跳
	positions.append(wa.position)
	var posInfos = []
	for pos in positions:
		posInfos.append({"x":pos.x,"y":pos.y})
	
	DataManager.set_env("战争.跃马可选位置", posInfos)
	var msg = "触发[{0}]跃马效果\n(请指定跃马位置)".format([
		wa.actor().get_steed().name()
	])
	SceneManager.show_unconfirm_dialog(msg)
	map.set_cursor_location(wa.position, true)
	map.show_color_block_by_position(positions)
	map.cursor.show()
	set_view_model(12)
	return

#检查空闲对白
func _check_wait_dialog():
	var wf = DataManager.get_current_war_fight()
	for wa in wf.get_war_actors(false):
		while not wa.wait_dialogs.empty():
			var d = wa.wait_dialogs.pop_front()
			if d.sceneId >= 30000:
				# 小战场或单挑的对话，忽略并丢弃
				continue
			DataManager.set_env("战争.玩家.等待对白", d.output())
			DataManager.set_env("战争.玩家.等待对白来源", wa.actorId)
			return true
	return false

# 托管战争询问
func player_delegate()->void:
	var msg = "确定要由 AI 指挥战争吗？\n战争完毕将自动结束托管\n托管中按住「开始」键可取消"
	SceneManager.show_yn_dialog(msg, DataManager.player_choose_actor)
	SceneManager.actor_dialog.lsc.cursor_index = 1
	set_view_model(886)
	return

# 托管战争
func player_delegate_confirmed()->void:
	var wf = DataManager.get_current_war_fight()
	var wv = wf.current_war_vstate()
	wv.delegate()
	FlowManager.add_flow("player_ready")
	return

func player_mercy()->void:
	var leaderId = DataManager.get_env_int("战争.放归.主将")
	var loserId = DataManager.get_env_int("战争.放归.目标")
	var leader = DataManager.get_war_actor(leaderId)
	var loser = DataManager.get_war_actor(loserId)
	if leader == null or loser == null:
		set_view_model(-1)
		FlowManager.add_flow("back_to_war_clear_trigger")
		return
	var msg = "擒获{0}\n可否释放？"
	if loser.actor().is_status_dead():
		msg = "{0}战败\n可否释放？"
	msg = msg.format([loser.get_name()])
	SceneManager.show_yn_dialog(msg, leader.actorId)
	set_view_model(40)
	return

func player_mercy_confirmed()->void:
	var leaderId = DataManager.get_env_int("战争.放归.主将")
	var loserId = DataManager.get_env_int("战争.放归.目标")
	var leader = DataManager.get_war_actor(leaderId)
	var loser = DataManager.get_war_actor(loserId)
	if leader == null or loser == null:
		set_view_model(-1)
		FlowManager.add_flow("back_to_war_clear_trigger")
		return
	var wf = DataManager.get_current_war_fight()
	wf.mercy_release(leader, loser)
	set_view_model(-1)
	FlowManager.add_flow("back_to_war_clear_trigger")
	return

func player_yijing() -> void:
	var actorId = DataManager.player_choose_actor
	var wa = DataManager.get_war_actor(actorId)
	if wa == null:
		FlowManager.add_flow("check_embattle_trigger")
		return
	wa.set_ext_variable("阴阳归道", 1)
	for info in SkillHelper.get_actor_scene_skills(wa.actorId, 20000):
		if Global.dic_val(info, "source", "") == "易经":
			pass
			#SkillHelper.remove_scene_actor_skill(20000, wa.actorId, info["skill_name"])
	var skills = get_yijing_skills(actorId)
	if skills.empty():
		FlowManager.add_flow("check_embattle_trigger")
		return
	var msg = "造化两仪，阴阳归道\n（{0}已转为「道」面".format([
		ActorHelper.actor(actorId).get_name(),
	])
	SceneManager.show_confirm_dialog(msg, actorId, 2)
	set_view_model(50)
	return

func player_yijing_select() -> void:
	var actorId = DataManager.player_choose_actor
	var skills = get_yijing_skills(actorId)
	var limit = min(4, skills.size())
	var lst = []
	# 兼容以前的 effectId
	var prevSelected = get_yijing_selected_skills(actorId)
	var msg = "选择「道」面技能（{0}/{1}）\n「B」键确认".format([
		prevSelected.size(), limit,
	])
	SceneManager.show_unconfirm_dialog(msg)
	SceneManager.bind_top_menu(skills, skills, 2)
	set_view_model(51)
	return

func player_yijing_selected() -> void:
	var actorId = DataManager.player_choose_actor
	var wa = DataManager.get_war_actor(actorId)
	var selected = get_yijing_selected_skills(actorId)
	var msg = "获得以下技能："
	var i = 0
	var unlocked = []
	for skill in selected:
		var sep = "、"
		if i % 2 == 0:
			sep = "\n"
		msg += sep + skill
		skill = skill.replace("（阳）", "")
		skill = skill.replace("（阴）", "")
		SkillHelper.add_actor_scene_skill(20000, actorId, skill, 99999, actorId, "易经")
		unlocked.append(skill)
		i += 1
	wa.set_war_side("道")
	SceneManager.show_confirm_dialog(msg, actorId)
	set_view_model(52)
	return

func get_yijing_skills(actorId:int) -> PoolStringArray:
	var skills = []
	for side in ["阴", "阳"]:
		for skillName in SkillHelper.get_actor_unlocked_skill_names(actorId, side).values():
			var skill = StaticManager.get_skill(skillName)
			if skill.has_feature("转换"):
				continue
			skills.append(skill.name + "（" + side + "）")
	return skills

func get_yijing_selected_skills(actorId:int) -> PoolStringArray:
	var skills = get_yijing_skills(actorId)
	var ret = []
	for skill in SkillHelper.get_skill_variable_array(10000, 20395, actorId):
		if skill in skills:
			ret.append(skill)
	return ret

func set_yijing_selected_skills(actorId:int, skills:PoolStringArray) -> void:
	SkillHelper.set_skill_variable(10000, 20395, actorId, skills, 99999)
	return
