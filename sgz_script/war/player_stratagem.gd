extends "war_base.gd"

#武将用计
func _init() -> void:
	LoadControl.view_model_name = "战争-玩家-步骤";
	
	FlowManager.bind_import_flow("stratagem_start", self)
	FlowManager.bind_import_flow("stratagem_choose_actor", self)
	FlowManager.bind_import_flow("stratagem_choose_area", self)
	FlowManager.bind_import_flow("stratagem_target_confirmed", self)
	FlowManager.bind_import_flow("stratagem_talk", self)
	FlowManager.bind_import_flow("stratagem_confirmed", self)
	FlowManager.bind_import_flow("stratagem_animation", self)
	FlowManager.bind_import_flow("stratagem_execute", self)
	FlowManager.bind_import_flow("stratagem_confirm_result", self)
	FlowManager.bind_import_flow("ask_for_continue_strategem", self)
	FlowManager.bind_import_flow("stratagem_trigger_1", self)
	FlowManager.bind_import_flow("stratagem_trigger_2", self)
	FlowManager.bind_import_flow("player_stratagem_mercy", self)
	FlowManager.bind_import_flow("player_stratagem_mercy_confirmed", self)
	return

#按键操控
func _input_key(delta: float):
	var scene_war:Control = SceneManager.current_scene();
	var war_map = scene_war.war_map;
	var bottom = SceneManager.lsc_menu;
	var top = SceneManager.lsc_menu_top;
	var view_model = LoadControl.get_view_model();
	var actorId = DataManager.player_choose_actor
	var me = DataManager.get_war_actor(actorId)
	var se = DataManager.get_current_stratagem_execution()	
	match view_model:
		121: # 选择用计目标
			var current = DataManager.get_env_int("武将")
			var disabled = DataManager.get_env_dict("战争.计策禁选")
			if not wait_for_choose_actor("stratagem_menu", false, false):
				var wa = DataManager.get_war_actor(current)
				war_map.set_cursor_location(wa.position, true)
				war_map.show_scheme_selector(se, me, wa.position)
				
				if str(current) in disabled:
					var reason = disabled[str(current)]
					var msg = "因{0}【{1}】效果\n不可对{2}发动{3}"
					if int(reason[0]) == current:
						msg = "因【{1}】效果\n不可对{2}发动{3}"
					msg = msg.format([
						ActorHelper.actor(reason[0]).get_name(), reason[1],
						ActorHelper.actor(current).get_name(), se.name,
					])
					SceneManager.show_unconfirm_dialog(msg, actorId, 3)
					SceneManager.dialog_msg_complete(true)
					war_map.next_shrink_actors = []
				else:
					var msg = "对何人发动{0}？".format([se.name])
					SceneManager.show_actor_info(wa.actorId, true, msg)
					war_map.next_shrink_actors = [wa.actorId]
			else:
				var selected = DataManager.get_env_int("目标")
				if str(selected) in disabled:
					LoadControl.set_view_model(121)
					return
				DataManager.set_env("战争.上次目标", selected)
				se.set_target(selected)
				FlowManager.add_flow("stratagem_target_confirmed")
		122: # 发动前确认对话
			var prevFlow = "stratagem_menu"
			if se.goback_disabled > 0:
				prevFlow = ""
			wait_for_confirmation("stratagem_confirmed", prevFlow)
		123: # 动画信息确认
			wait_for_confirmation("stratagem_execute")
		124: # 最终确认
			if not Global.is_action_pressed_AX():
				return
			if not SceneManager.dialog_msg_complete(true):
				return
			LoadControl.set_view_model(-1)
			var msgs = DataManager.get_env_array("对话PENDING")
			if not msgs.empty():
				FlowManager.add_flow("stratagem_confirm_result")
				return
			FlowManager.add_flow("stratagem_trigger_1")
		125: # 询问是否连策
			if Input.is_action_just_pressed("ANALOG_LEFT"):
				SceneManager.actor_dialog.move_left()
			if Input.is_action_just_pressed("ANALOG_RIGHT"):
				SceneManager.actor_dialog.move_right()
			if not Global.is_action_pressed_AX():
				return
			if not SceneManager.dialog_msg_complete(true):
				return
			LoadControl.set_view_model(-1)
			var option = SceneManager.actor_dialog.lsc.cursor_index
			_set_continue_stragem_set(se.name, option)
			match option:
				0:
					FlowManager.add_flow("stratagem_start")
				1:
					FlowManager.add_flow("player_ready")
		126:
			Global.wait_for_yesno("player_stratagem_mercy_confirmed", "player_ready")
	return

func stratagem_start():
	var stratagem = get_env_str("值")
	var se = DataManager.new_stratagem_execution(DataManager.player_choose_actor, stratagem)
	var war_map = SceneManager.current_scene().war_map
	war_map.show_scheme_selector()
	if se.is_area_targeting():
		FlowManager.add_flow("stratagem_choose_area")
	else:
		FlowManager.add_flow("stratagem_choose_actor")
	return

#选择对何人使用
func stratagem_choose_actor():
	var se = DataManager.get_current_stratagem_execution()
	var fromWA = DataManager.get_war_actor(se.fromId)
	var war_map = SceneManager.current_scene().war_map

	# 距离的判断比较特殊，暂时单独 clear 一下
	DataManager.unset_env("计策.ONCE.距离")
	SkillHelper.auto_trigger_skill(se.fromId, 20026, "")
	var res = se.get_available_targets()
	var targets = Array(res[0])
	var disabled = Dictionary(res[1])
	DataManager.set_env("战争.计策禁选", disabled)
	var disabledTargets = []
	for disabledId in disabled.keys():
		disabledTargets.append(int(disabledId))
	targets.append_array(disabledTargets)
	if targets.empty():
		war_map.cursor.hide()
		war_map.show_scheme_selector(se, fromWA)
		LoadControl._error(se.get_error_message(), se.fromId)
		return

	war_map.cursor.show()
	var targetId = targets[0]
	DataManager.set_env("可选目标", targets)
	#如果上次用计的目标仍然是可用计的目标
	var lastTargetId = DataManager.get_env_int("战争.上次目标")
	if lastTargetId >= 0 and lastTargetId in targets:
		targetId = lastTargetId
		DataManager.unset_env("战争.上次目标")
	#特殊计策的优先目标判断逻辑
	if se.name == "虚兵":
		targets.erase(targetId)
		targets.insert(0, targetId)
		for id in targets:
			var wa = DataManager.get_war_actor(id)
			if wa.get_buff_label_turn(["禁止移动"]) == 0:
				targetId = id
				break
	targets.erase(targetId)
	targets.insert(0, targetId)
	DataManager.set_env("武将", targetId)
	var targetWA = DataManager.get_war_actor(targetId)
	war_map.set_cursor_location(targetWA.position, true)
	SkillHelper.auto_trigger_skill(se.fromId, 20021, "")
	war_map.next_shrink_actors = [targetId]
	war_map.show_scheme_selector(se, fromWA, targetWA.position)
	war_map.show_can_choose_actors(targets, se.fromId, disabledTargets)
	var msg = "对何人发动{0}？".format([se.name])
	DataManager.set_env("对话", msg)
	SceneManager.show_actor_info(targetWA.actorId, true, msg)
	LoadControl.set_view_model(121)
	return

#选择地点
func stratagem_choose_area():
	var se = DataManager.get_current_stratagem_execution()
	se.set_target(-1)
	var war_map = SceneManager.current_scene().war_map
	war_map.cursor.hide()
	var wa = DataManager.get_war_actor(se.fromId)
	# 目前暂无选择用计地点的逻辑，只有十面埋伏
	# 故将原本选择地点的分支（view_model=131）暂时简化掉，未来有了再加
	var error = se.stratagem.check_area_correct(se.fromId, wa.position)
	if error != "":
		LoadControl._error(error, se.fromId)
		return
	se.set_target(se.fromId)
	DataManager.set_target_position(wa.position)
	FlowManager.add_flow("stratagem_target_confirmed")
	return

func stratagem_target_confirmed():
	var se = DataManager.get_current_stratagem_execution()
	se.decide_cost()

	var war_map = SceneManager.current_scene().war_map
	war_map.show_scheme_selector()
	war_map.show_can_choose_actors([se.targetId], se.fromId)
	war_map.next_shrink_actors.clear()
	war_map.cursor.show()

	# 支持 flow，支持替代用计，支持修改对白
	if SkillHelper.auto_trigger_skill(se.fromId, 20018, "stratagem_talk"):
		return
	FlowManager.add_flow("stratagem_talk")
	return

#播放对白
func stratagem_talk():
	var se = DataManager.get_current_stratagem_execution()
	var msg = se.get_message()
	if msg == "":
		FlowManager.add_flow("stratagem_confirmed")
		return
	var war_map = SceneManager.current_scene().war_map
	war_map.cursor.show()
	war_map.next_shrink_actors.clear()
	SceneManager.show_confirm_dialog(msg, se.get_action_id(se.hiddenActionId));
	LoadControl.set_view_model(122)
	return

func stratagem_confirmed():
	var se = DataManager.get_current_stratagem_execution()
	# 在这里执行并记录消耗
	se.perform_cost()
	if se.targetId >= 0 and se.targetId != se.get_action_id(se.fromId):
		if SkillHelper.auto_trigger_skill(se.targetId, 20038, "stratagem_animation"):
			return
	FlowManager.add_flow("stratagem_animation")
	return

#播放动画
func stratagem_animation():
	var se = DataManager.get_current_stratagem_execution()
	var war_map = SceneManager.current_scene().war_map
	war_map.cursor.hide()

	var wa = DataManager.get_war_actor(se.fromId)
	var targets = [];
	if se.fromId != se.targetId:
		var targetWA = DataManager.get_war_actor(se.targetId)
		if targetWA != null:
			targets = se.get_affected_actors(targetWA.position)
		else:
			targets = se.get_affected_actors(wa.position)

	# 计算并显示命中率
	var rate = se.get_rate(targets)
	var rawRate = se.get_raw_rate(targets)

	# 播放动画同时，清空大战场可选定的人员
	war_map.clear_can_choose_actors()

	var msg = "计策命中率：{0}({3}{1})%";
	if targets.size() > 1:
		msg = "对{2}人综合命中率：{0}({3}{1})%";
	var signChar = "+"
	if rate < rawRate:
		signChar = ""
	msg = msg.format([rawRate, rate - rawRate, targets.size(), signChar])
	var animTargetId = se.targetId
	if targets.size() > 1:
		animTargetId = -1
	SceneManager.play_war_animation(
		se.get_animation(), animTargetId, "",
		msg, se.get_action_id(se.hiddenActionId), 2
	)
	LoadControl.set_view_model(123)
	return

#动画后执行
func stratagem_execute():
	var se = DataManager.get_current_stratagem_execution()
	var wa = DataManager.get_war_actor(se.fromId)
	var targets = []
	if se.fromId == se.targetId:
		targets = se.get_affected_actors(wa.position)
	else:
		var targetWA = DataManager.get_war_actor(se.targetId)
		if targetWA != null:
			targets = se.get_affected_actors(targetWA.position)
		else:
			targets = se.get_affected_actors(wa.position)

	#执行结果
	var successful = false
	if se.is_area_targeting():
		var areaPosition = DataManager.get_target_position()
		se.perform_to_area(areaPosition)
	else:
		se.perform_to_targets(targets)
	SkillHelper.auto_trigger_skill(se.get_action_id(se.hiddenActionId), 20009, "")
	FlowManager.add_flow("draw_actors")

	DataManager.set_env("对话PENDING", se.get_report_message())
	FlowManager.add_flow("stratagem_confirm_result")
	return

#确认结果
func stratagem_confirm_result():
	var se = DataManager.get_current_stratagem_execution()
	var speakerWA = DataManager.get_war_actor(se.fromId)
	var msgs = DataManager.get_env_array("对话PENDING")
	DataManager.unset_env("对话PENDING")
	if msgs.empty():
		msgs.append_array(se.get_report_message(speakerWA))
	if msgs.size() > 3:
		DataManager.set_env("对话PENDING", msgs.slice(3, msgs.size()-1))
		msgs = msgs.slice(0, 2)
	SceneManager.show_confirm_dialog("\n".join(msgs), speakerWA.actorId, se.reporter_mood)
	LoadControl.set_view_model(124)
	return

func try_release_loser(se:StratagemExecution) -> bool:
	if se.succeeded <= 0:
		return false
	if not se.damage_hp():
		return false
	var loser = DataManager.get_war_actor(se.targetId)
	if loser == null or not loser.disabled:
		return false
	var winner = DataManager.get_war_actor(se.fromId)
	if winner == null:
		return false
	var leader = winner.get_leader()
	if leader == null:
		return false
	# 主将不豁免
	if loser.actorId == loser.get_main_actor_id():
		return false
	if leader.actor().get_equip_feature_max("豁免敌将") <= 0:
		return false
	if leader.get_controlNo() < 0:
		# AI 看心情
		if not Global.get_rate_result(30):
			return false
		var wf = DataManager.get_current_war_fight()
		wf.mercy_release(leader, loser)
		return false
	# 玩家需要询问
	DataManager.set_env("战争.放归.主将", leader.actorId)
	DataManager.set_env("战争.放归.目标", loser.actorId)
	FlowManager.add_flow("player_stratagem_mercy")
	return true

#用计者触发诱发
func stratagem_trigger_1():
	var se = DataManager.get_current_stratagem_execution()
	if try_release_loser(se):
		return
	se.report()
	if SkillHelper.auto_trigger_skill(se.get_action_id(se.hiddenActionId), 20012, "stratagem_trigger_2"):
		return
	FlowManager.add_flow("stratagem_trigger_2")
	return

#被用计者触发
func stratagem_trigger_2():
	var se = DataManager.get_current_stratagem_execution()
	if se.targetId >= 0:
		if SkillHelper.auto_trigger_skill(se.targetId, 20012, "ask_for_continue_strategem"):
			return
	FlowManager.add_flow("ask_for_continue_strategem")
	return

#连策询问
func ask_for_continue_strategem():
	var se = DataManager.get_current_stratagem_execution()
	se.report()
	if se.skip_redo:
		se.skip_redo = 0
		FlowManager.add_flow("player_ready")
		return
	# 忽略禁用状态强行发起计策的情况，禁止连策
	var me = DataManager.get_war_actor(se.fromId)
	if me == null or me.get_buff_label_turn(["禁用计策"]) > 0:
		FlowManager.add_flow("player_ready")
		return
	# 特殊规则，虚兵成功后，如果没有合适的虚兵目标，不连策
	if se.name == "虚兵" and se.succeeded:
		var allStopped = true
		for targetId in se.get_available_targets()[0]:
			var wa = DataManager.get_war_actor(targetId)
			if wa.get_buff_label_turn(["禁止移动"]) == 0:
				allStopped = false
				break
		if allStopped:
			FlowManager.add_flow("player_ready")
			return
	if not se.performable():
		FlowManager.add_flow("player_ready")
		return
	SceneManager.show_yn_dialog("是否继续使用{0}?".format([se.name]))
	var lastOption = _get_continue_stragem_set(se.name)
	SceneManager.actor_dialog.lsc.cursor_index= lastOption
	LoadControl.set_view_model(125)
	return

#获取连策设置
func _get_continue_stragem_set(stratagem:String)->int:
	return 0

#设置连策设置
func _set_continue_stragem_set(stratagem:String,index:int):
	var cname = "战争.{0}连策".format([stratagem]);
	DataManager.common_variable[cname] = index;

func player_stratagem_mercy()->void:
	var leaderId = DataManager.get_env_int("战争.放归.主将")
	var loserId = DataManager.get_env_int("战争.放归.目标")
	var leader = DataManager.get_war_actor(leaderId)
	var loser = DataManager.get_war_actor(loserId)
	if leader == null or loser == null:
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("player_ready")
		return
	var msg = "擒获{0}\n可否释放？"
	if loser.actor().is_status_dead():
		msg = "{0}战败\n可否释放？"
	msg = msg.format([loser.get_name()])
	SceneManager.show_yn_dialog(msg, leader.actorId)
	LoadControl.set_view_model(126)
	return

func player_stratagem_mercy_confirmed()->void:
	var leaderId = DataManager.get_env_int("战争.放归.主将")
	var loserId = DataManager.get_env_int("战争.放归.目标")
	var leader = DataManager.get_war_actor(leaderId)
	var loser = DataManager.get_war_actor(loserId)
	if leader == null or loser == null:
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("player_ready")
		return
	var wf = DataManager.get_current_war_fight()
	wf.mercy_release(leader, loser)
	LoadControl.set_view_model(-1)
	FlowManager.add_flow("player_ready")
	return
