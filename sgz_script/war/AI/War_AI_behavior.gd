extends Resource

# 基础的 AI 行动逻辑流程

const view_model_name = "战争-AI-步骤"
const VAR_CUR_ACTOR = "AI-当前武将"
const VAR_END_ACTOR = "AI-停止武将"

var wab;
var was;
var iwa;

var lastBehaviorActorId = -1
var currentBehaviorActorId = -1

# 记录计策的释放，不必存储
var scheme_history = {}

func trace_on()->bool:
	return true

func trace(info:String):
	if self.trace_on():
		DataManager.game_trace(info)

func get_view_model()->int:
	return DataManager.get_env_int(view_model_name)

func set_view_model(view_model:int)->void:
	DataManager.set_env(view_model_name, view_model)
	return

#AI行为逻辑
func _init() -> void:
	iwa = Global.load_script(DataManager.mod_path+"sgz_script/war/IWar_Attack.gd")
	wab = Global.load_script(DataManager.mod_path+"sgz_script/war/AI/War_AI_Battle.gd")
	was = Global.load_script(DataManager.mod_path+"sgz_script/war/AI/War_AI_Strategy.gd")
	
	FlowManager.bind_import_flow("AI_attack_0", self)
	FlowManager.bind_import_flow("AI_attack_1", self)
	FlowManager.bind_import_flow("AI_retreat_0", self)
	FlowManager.bind_import_flow("AI_retreat_1", self)
	FlowManager.bind_import_flow("AI_move_0", self)
	FlowManager.bind_import_flow("AI_move_1", self)
	FlowManager.bind_import_flow("AI_move_2", self)

	# 计策相关 flow
	FlowManager.bind_import_flow("AI_strategem_0", self)
	FlowManager.bind_import_flow("AI_stratagem_talk", self)
	FlowManager.bind_import_flow("AI_stratagem_confirmed", self)
	FlowManager.bind_import_flow("AI_strategem_execute_trigger", self)
	FlowManager.bind_import_flow("AI_stratagem_talk_2", self)
	FlowManager.bind_import_flow("AI_strategem_execute", self)
	FlowManager.bind_import_flow("AI_strategem_1", self)
	FlowManager.bind_import_flow("AI_strategem_end_1_trigger", self)
	FlowManager.bind_import_flow("AI_strategem_end_2_trigger", self)
	FlowManager.bind_import_flow("AI_stratagem_done", self)
	return

#-----------------按键操控--------------------------
func _input_key(delta: float):
	match get_view_model():
		10: # AI用计确认
			Global.wait_for_confirmation("AI_stratagem_confirmed", view_model_name)
		101: # AI 用计插入对话确认
			Global.wait_for_confirmation("AI_strategem_execute_trigger", view_model_name)
		11: # AI用计结果确认
			if Global.wait_for_confirmation("", view_model_name):
				var msgs = DataManager.get_env_array("对话PENDING")
				if not msgs.empty():
					FlowManager.add_flow("AI_strategem_1")
					return
				FlowManager.add_flow("AI_strategem_end_1_trigger")
		20:#AI攻击确认
			Global.wait_for_confirmation("AI_attack_1", view_model_name)
		30:#AI撤退确认
			Global.wait_for_confirmation("AI_retreat_1", view_model_name)
		41:#减兵确认
			Global.wait_for_confirmation("AI_move_2")
	return

func AI_move_0():
	var fromId = _get_current_actor_id()
	var wa = DataManager.get_war_actor(fromId)
	var actor = ActorHelper.actor(fromId)
	var fromPositionDic = DataManager.get_env_dict("当前坐标")
	var fromPosition = Vector2(-1, -1)
	if not fromPositionDic.empty():
		fromPosition = Vector2(fromPositionDic["x"], fromPositionDic["y"])
	var toPositionDic = DataManager.get_env_dict("目标坐标")
	var toPosition = Vector2(toPositionDic["x"], toPositionDic["y"])
	if fromPosition != Vector2(-1, -1) and wa.position != fromPosition:
		return
	var cost = DataManager.get_move_cost(wa.actorId, toPosition)
	if cost["机"] > 0:
		wa.action_point = max(0, wa.action_point - cost["机"])
	if cost["点"] > 0:
		wa.poker_point = max(0, wa.poker_point - cost["点"])
	
	var war_map = SceneManager.current_scene().war_map
	if wa.play_move(toPosition, false):
		yield(war_map, "actor_move_complete")
		war_map.draw_actors()

	war_map.cursor_position = toPosition
	war_map.update_ap()
	war_map.fix_cursor_camer()
	DataManager.set_env("移动", 1)
	DataManager.set_env("移动消耗", cost)
	DataManager.unset_env("结束移动")
	#插入移动技能判定
	SkillHelper.auto_trigger_skill(fromId, 20003, "")
	var trapInfo = wa.check_has_areas_by_labels(["伏兵"])
	if not trapInfo.empty():
		#十面埋伏扣兵
		var trapActor = ActorHelper.actor(int(trapInfo["from_actorId"]))
		var damage = int(Global.get_random(30,40) * trapActor.get_wisdom() / 10)
		damage = int(min(damage, actor.get_soldiers()) * min(1,max(0.1,trapActor.get_soldiers()/1000.0)))
		var msg = "{0}遭遇伏兵".format([wa.get_name()])
		# 暂时植入【破伏】的实现
		if SkillHelper.actor_has_skills(wa.actorId, ["破伏"]):
			damage = 0
			msg += "\n{0}【破伏】免伤".format([wa.get_name()])
		if damage > 0:
			DataManager.damage_sodiers(trapActor.actorId, actor.actorId, damage)
			msg += "\n兵力下降{0}".format([damage])
		DataManager.set_env("对话", msg)
		if trapInfo.has("pos"):
			war_map.mark_area_trapped(false, trapInfo["pos"], 2)
		FlowManager.add_flow("AI_move_1")
		FlowManager.add_flow("draw_actors")
		return
	FlowManager.add_flow("AI_move_2")
	return

func AI_move_1():
	SceneManager.show_confirm_dialog(DataManager.common_variable["对话"])
	set_view_model(41)
	return

# 停止移动后
func AI_move_2():
	var fromId = _get_current_actor_id()
	var wa = DataManager.get_war_actor(fromId)
	if wa != null:
		DataManager.set_env("移动", 0)
		DataManager.set_env("结束移动", 1)
		wa.after_move()
		if SkillHelper.auto_trigger_skill(fromId, 20003, "AI_before_ready"):
			return
	FlowManager.add_flow("AI_before_ready")
	return

#AI用计
func _strategem(wa:War_Actor, targetId:int, stratagem:String)->bool:
	# 防止连锁技能未执行完毕
	# 临时方案，阻断计策流程被插入的 AI_ready 打断
	# 导致 StratagemExecution 对象的执行乱序
	# 未来应考虑 AI 行动串行化或技能串行化
	#var st = SkillHelper.get_current_skill_trigger();
	#if st != null:
	#	return false
	if wa.get_buff_label_turn(["禁用计策"]) > 0:
		return false
	var key = "战争.计策.允许.{0}".format([wa.actorId])
	DataManager.set_env(key, 1)
	DataManager.set_env("计策名", stratagem)
	DataManager.set_env("目标", targetId)

	# 触发判断，是否可发动计策，不支持 flow，可以在 key 中返回错误信息
	SkillHelper.auto_trigger_skill(wa.actorId, 20024, "")
	if DataManager.get_env_int(key) != 1:
		return false
	
	var war_map = SceneManager.current_scene().war_map
	war_map.camer_to_actorId(wa.actorId, "AI_strategem_0")
	return true

#AI攻击
func _attack(wa:War_Actor, targetId:int)->bool:
	var bf = DataManager.get_current_battle_fight()
	if bf.fromId == wa.actorId and bf.status == 0:
		# 等待之前的攻击执行完成
		return false
	if wa.get_buff_label_turn(["禁止攻击"])>0:
		return false
	# 再次检查是否可攻击
	# 同时检查了机动力，后面不用再检查了
	# 但与之前的 best targets 有重复判断，未来应优化掉 TODO
	if not targetId in iwa.get_can_attack_actors(wa.actorId)[0]:
		return false
	if not DataManager.endless_model:
		if wa.get_soldiers() <= 0 and wa.actor().get_hp() < 40:
			return false
	DataManager.set_env("目标", targetId)
	SceneManager.current_scene().war_map.camer_to_actorId(wa.actorId, "AI_attack_0")
	return true
	
#AI撤退（兵力<=200，有城能撤就必撤）
func _retreat(wa:War_Actor)->bool:
	if DataManager.game_mode2 == 1:
		#剧情模式不撤退
		return false
	if DataManager.endless_model:
		# 无尽模式不撤退
		return false
	if wa.get_buff_label_turn(["围困"]) > 0:
		# 围困状态下不允许撤退
		return false
	var actor = wa.actor()
	if actor.get_soldiers() > 200:
		if actor.get_hp() > 15:
			return false
		if not actor.is_injured():
			return false
	if wa.actorId == wa.get_main_actor_id():
		# 如果我是主将
		if wa.war_vstate().get_war_actors(false, true).size() > 1:
			# 且仍有其他队友
			var nearbyEnemies = false
			for enemy in wa.war_vstate().get_enemy_vstate().get_war_actors(false, true):
				if Global.get_distance(enemy.position, wa.position) <= 6:
					nearbyEnemies = true
			if not nearbyEnemies:
				# 且周围并没有敌军
				# 不撤退，但也不再前进
				_end_action(wa)
				return true

	var targetCityId = wa.get_retreat_city_id()
	if targetCityId < 0:
		# 无路可退
		return false
	DataManager.set_env("撤退城", targetCityId)
	var map = SceneManager.current_scene().war_map
	map.camer_to_actorId(wa.actorId, "AI_retreat_0")
	set_view_model(-1)
	return true

#-----------------计策步骤--------------------------
# 发起计策提示信息
func AI_strategem_0():
	var fromId = _get_current_actor_id()
	var stratagemName = DataManager.get_env_str("计策名")
	var se = DataManager.new_stratagem_execution(fromId, stratagemName)
	var me = DataManager.get_war_actor(se.fromId)
	se.set_target(DataManager.get_env_int("目标"))
	SkillHelper.auto_trigger_skill(se.fromId, 20021, "")
	FlowManager.add_flow("AI_stratagem_talk")
	return

func AI_stratagem_talk():
	var se = DataManager.get_current_stratagem_execution()
	var me = DataManager.get_war_actor(se.fromId)
	var targetWA = DataManager.get_war_actor(se.targetId)
	var war_map = SceneManager.current_scene().war_map
	war_map.next_shrink_actors = [se.fromId, se.targetId]
	war_map.show_scheme_selector(se, me, targetWA.position)
	var targetControl = targetWA.get_controlNo()
	FlowManager.set_current_control_playerNo(max(targetControl, 0))
	if targetControl >= 0:
		SceneManager.show_confirm_dialog("敌军({1})使用计策【{0}】".format([
			se.name, ActorHelper.actor(se.fromId).get_name()
		]), se.targetId, 0)
	else:
		SceneManager.show_confirm_dialog(se.get_message(), se.fromId)
	SoundManager.play_se("res://resource/sounds/se/AI_Strategy.ogg")
	set_view_model(10)
	return

# 目标选定，信息已确认
func AI_stratagem_confirmed():
	var se = DataManager.get_current_stratagem_execution()
	se.decide_cost()
	se.message = ""
	if SkillHelper.auto_trigger_skill(se.fromId, 20018, "AI_stratagem_talk_2"):
		return
	FlowManager.add_flow("AI_stratagem_talk_2")
	return

func AI_stratagem_talk_2():
	var se = DataManager.get_current_stratagem_execution()
	if se.message == "":
		FlowManager.add_flow("AI_strategem_execute_trigger")
		return
	SceneManager.show_confirm_dialog(se.message, se.get_action_id(se.hiddenActionId))
	set_view_model(101)
	return

# 执行前触发
func AI_strategem_execute_trigger():
	var se = DataManager.get_current_stratagem_execution()
	se.perform_cost()
	# 调用这个只是为了记录命中率
	if se.targetId >= 0 and se.targetId != se.get_action_id(se.fromId):
		se.get_rate([se.targetId])
		if SkillHelper.auto_trigger_skill(se.targetId, 20038, "AI_strategem_execute"):
			return
	FlowManager.add_flow("AI_strategem_execute")
	return

# 执行计策
func AI_strategem_execute():
	var se = DataManager.get_current_stratagem_execution()
	var me = DataManager.get_war_actor(se.fromId)
	var targetWA = DataManager.get_war_actor(se.targetId)
	var targets = se.get_affected_actors(targetWA.position)
	se.perform_to_targets(targets)
	SkillHelper.auto_trigger_skill(se.get_action_id(se.hiddenActionId), 20009, "")
	var war_map = SceneManager.current_scene().war_map
	war_map.update_ap()
	var speakerWA = targetWA
	# 对队友用计、被笼络、被杀，均为敌方发言
	if speakerWA == null or speakerWA.disabled or not me.is_enemy(speakerWA):
		speakerWA = me.get_war_enemy_leader()
		if not me.is_enemy(speakerWA):
			speakerWA = me
	elif speakerWA.get_controlNo() < 0:
		# 目标为 AI，自己发言
		speakerWA = me
	DataManager.set_env("对话PENDING", se.get_report_message(speakerWA, me))
	FlowManager.add_flow("AI_strategem_1")
	FlowManager.add_flow("draw_actors")
	return

# 汇报计策结果
func AI_strategem_1():
	var se = DataManager.get_current_stratagem_execution()
	var me = DataManager.get_war_actor(se.fromId)
	var speakerWA = DataManager.get_war_actor(se.targetId)
	# 对队友用计、被笼络、被杀，均为敌方发言
	if speakerWA == null or speakerWA.disabled or not me.is_enemy(speakerWA):
		speakerWA = me.get_war_enemy_leader()
		if not me.is_enemy(speakerWA):
			speakerWA = me
	elif speakerWA.get_controlNo() < 0:
		# 目标为 AI，自己发言
		speakerWA = me
	var msgs = DataManager.get_env_array("对话PENDING")
	DataManager.unset_env("对话PENDING")
	if msgs.empty():
		msgs.append_array(se.get_report_message(speakerWA, me))
	if msgs.size() > 3:
		DataManager.set_env("对话PENDING", msgs.slice(3, msgs.size()-1))
		msgs = msgs.slice(0, 2)
	var war_map = SceneManager.current_scene().war_map
	war_map.update_ap()
	SceneManager.show_confirm_dialog("\n".join(msgs), speakerWA.actorId, se.reporter_mood)
	set_view_model(11)
	return

# AI用计结束(用计者触发事件)
func AI_strategem_end_1_trigger():
	var war_map = SceneManager.current_scene().war_map
	war_map.show_scheme_selector()
	var se = DataManager.get_current_stratagem_execution()
	var fromActor = ActorHelper.actor(se.fromId)
	var msg = "{0}用计".format([fromActor.get_name()])
	if se.succeeded > 0:
		msg += "成功"
	else:
		msg += "失败"
	if SkillHelper.auto_trigger_skill(se.fromId, 20012, "AI_strategem_end_2_trigger", msg):
		return
	FlowManager.add_flow("AI_strategem_end_2_trigger")
	set_view_model(12)
	return

# AI用计结束(被用计者触发事件)
func AI_strategem_end_2_trigger():
	var se = DataManager.get_current_stratagem_execution()
	var fromActor = ActorHelper.actor(se.fromId)
	var msg = "{0}用计".format([fromActor.get_name()])
	if se.succeeded > 0:
		msg += "成功"
	else:
		msg += "失败"
	if SkillHelper.auto_trigger_skill(se.targetId, 20012, "AI_stratagem_done", msg):
		return
	FlowManager.add_flow("AI_stratagem_done")
	return

func AI_stratagem_done():
	var se = DataManager.get_current_stratagem_execution()
	se.report()
	# 记录计策的释放
	record_scheme_history(se)
	FlowManager.add_flow("AI_before_ready")
	return

#-----------------攻击步骤--------------------------
func AI_attack_0():
	set_view_model(20);
	var targetId = DataManager.get_env_int("目标")
	var fromId = DataManager.get_env_int(VAR_CUR_ACTOR)
	var war_map = SceneManager.current_scene().war_map;
	war_map.next_shrink_actors = [fromId];
	var war_tar = DataManager.get_war_actor(targetId);
	var from_actor = ActorHelper.actor(fromId)
	var confirm_control = war_tar.get_controlNo();
	if(confirm_control<0):
		confirm_control = 0;
	FlowManager.set_current_control_playerNo(confirm_control);
	SceneManager.show_confirm_dialog("敌将({0})发起攻击!".format([from_actor.get_name()]),targetId,0);
	war_map.update_ap();#立刻更新机动力显示
	
func AI_attack_1():
	set_view_model(21);
	DataManager.battle_units = []
	SceneManager.hide_all_tool()
	var war_map = SceneManager.current_scene().war_map
	war_map.next_shrink_actors = []
	var actorId = DataManager.get_env_int(VAR_CUR_ACTOR)
	var targetId = DataManager.get_env_int("目标")
	DataManager.player_choose_actor = actorId
	DataManager.set_env("武将", targetId)
	var iatk = Global.load_script("res://resource/sgz_script/war/player_attack.gd")
	iatk._go_to_battle()
	return

#-----------------撤退步骤--------------------------
func AI_retreat_0():
	var actorId = DataManager.get_env_int(VAR_CUR_ACTOR)
	var war_map = SceneManager.current_scene().war_map;
	war_map.next_shrink_actors = [actorId]
	var wa = DataManager.get_war_actor(actorId)
	var confirm_control = wa.war_vstate().get_main_controlNo()
	if confirm_control < 0:
		confirm_control = wa.war_vstate().get_enemy_vstate().get_main_controlNo()
		if confirm_control < 0:
			confirm_control = 0
	FlowManager.set_current_control_playerNo(confirm_control)
	SceneManager.show_confirm_dialog("{0}已撤退!".format([wa.get_name()]))
	set_view_model(30)
	return

func AI_retreat_1():
	SceneManager.hide_all_tool()
	var war_map = SceneManager.current_scene().war_map
	war_map.next_shrink_actors = []
	var actorId = DataManager.get_env_int(VAR_CUR_ACTOR)
	var wa = DataManager.get_war_actor(actorId)
	var retreatCityId = DataManager.get_env_int("撤退城")
	wa.retreat_to(retreatCityId)
	FlowManager.add_flow("draw_actors")
	FlowManager.add_flow("AI_before_ready")
	return

#AI 回合结束时，响应外层 flow 的调用，执行清理工作
func AI_end():
	lastBehaviorActorId = -1
	currentBehaviorActorId = -1
	scheme_history.clear()

# 记录计策释放的历史
func record_scheme_history(se:StratagemExecution)->void:
	var key = str(se.fromId)
	if not scheme_history.has(key):
		scheme_history[key] = []
	scheme_history[key].append(se)
	return

# 结束行动回合
func _end_action(wa:War_Actor)->void:
	var endActors = DataManager.get_env_int_array(VAR_END_ACTOR)
	endActors.append(wa.actorId)
	DataManager.set_env(VAR_END_ACTOR, endActors)
	self.trace("   #{0}{1} 终止行动, 机动力 {2} 策略：{3}".format([
		wa.actorId, wa.get_name(), wa.action_point, wa.AI,
	]))
	# 立刻更新机动力显示
	var war_map = SceneManager.current_scene().war_map
	war_map.update_ap()
	FlowManager.add_flow("AI_before_ready")
	return

# 这里遇到变量配合问题时，有时会发生异常
# 统一做一个处理
func _get_current_actor_id()->int:
	var actorId = DataManager.get_env_int(VAR_CUR_ACTOR)
	if actorId < 0:
		print("ERROR: {0}异常，请检查逻辑".format([VAR_CUR_ACTOR]))
		actorId = DataManager.player_choose_actor
	return actorId

func _can_buy_rice_numbers(wvId:int)->int:
	var wf = DataManager.get_current_war_fight()
	var wv = wf.get_war_vstate(wvId)
	var need_rice = wv.get_actors_count() * 4 * 8
	if wv.rice >= need_rice:
		return 0
	var all_money_can_buy_rice = int(wv.money * wf.target_city().get_rice_buy_price() / 100)
	var buy_rice = min(need_rice, all_money_can_buy_rice)
	return int(max(0, buy_rice))

# 在计策命中率低下时，是否仍考虑用计
func _try_scheme_however(wa:War_Actor)->bool:
	if wa.side() != "防守方":
		return false
	if wa.actor().get_wisdom() < 80:
		return false
	return true
