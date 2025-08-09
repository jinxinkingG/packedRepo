extends Resource
const view_model_name = "白兵战-玩家-步骤";

var itactic;

#战术
func _init() -> void:
	LoadControl.view_model_name = view_model_name;
	itactic = Global.load_script(DataManager.mod_path+"sgz_script/battle/ITactic.gd")
	
	FlowManager.bind_signal_method("player_tactic", self)
	FlowManager.bind_signal_method("tactic_end", self)
	FlowManager.bind_signal_method("tactic_start", self)
	FlowManager.bind_signal_method("tactic_impact_0", self)
	FlowManager.bind_signal_method("tactic_impact_1", self)
	FlowManager.bind_signal_method("tactic_impact_2", self)
	FlowManager.bind_signal_method("tactic_impact_3", self)
	FlowManager.bind_signal_method("tactic_impact_4", self)
	FlowManager.bind_signal_method("tactic_skills", self)

	FlowManager.clear_pre_history.append("player_tactic")
	FlowManager.clear_pre_history.append("tactic_end")
	FlowManager.clear_pre_history.append("tactic_impact_0")
	FlowManager.clear_pre_history.append("tactic_impact_1")
	FlowManager.clear_pre_history.append("tactic_impact_2")
	FlowManager.clear_pre_history.append("tactic_impact_3")
	FlowManager.clear_pre_history.append("tactic_impact_4")
	return


func _input_key(delta: float):
	var scene_battle:Control = SceneManager.current_scene()
	if scene_battle.SCENE_ID != 30000:
		return
	if scene_battle.battle_log.visible:
		return
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	var actorId = int(DataManager.common_variable["当前武将"]);
	var war_actor = DataManager.get_war_actor(actorId);
	match view_model:
		100:#战术列表
			var battle_tactic = scene_battle.battle_tactic;
			if(Input.is_action_just_pressed("ANALOG_UP")):
				battle_tactic.move_up();
			if(Input.is_action_just_pressed("ANALOG_DOWN")):
				battle_tactic.move_down();
			if(Input.is_action_just_pressed("ANALOG_LEFT")):
				battle_tactic.move_left();
			if(Input.is_action_just_pressed("ANALOG_RIGHT")):
				battle_tactic.move_right();
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				LoadControl.set_view_model(-1)
				FlowManager.add_flow("tactic_start")
				return
			if(Global.is_action_pressed_BY()):
				if(!SceneManager.dialog_msg_complete(false)):
					return;
				LoadControl.set_view_model(-1)
				FlowManager.add_flow("tactic_end");
		101:#非单挑的战术发动文字确认
			Global.wait_for_confirmation("tactic_end")
		102:#单挑确认
			if not Global.wait_for_confirmation(""):
				return
			var result = DataManager.get_env_int("结果")
			if result == 1:
				var battle_tactic = scene_battle.battle_tactic
				battle_tactic.hide()
				FlowManager.add_flow("go_to_solo")
			else:
				FlowManager.add_flow("tactic_end")
	return

func player_tactic():
	var actorId = DataManager.get_env_int("当前武将")
	var scene_battle = SceneManager.current_scene()
	scene_battle.battle_tactic.init_data(actorId)
	scene_battle.battle_tactic.show()
	LoadControl.set_view_model(100)
	return

func tactic_end():
	var scene = SceneManager.current_scene()
	match scene.SCENE_ID:
		30000:
			scene.battle_tactic.hide()
			scene.battle_state.hide()
			scene.main_bottom.update_data()
			scene.main_bottom.show()
			LoadControl.set_view_model(-1)
			LoadControl.end_script()
			FlowManager.add_flow("unit_action")
		40000:
			# 有可能触发后进入单挑
			LoadControl.set_view_model(-1)
			LoadControl.end_script()
			FlowManager.add_flow("solo_run_start")
	return

func tactic_start():
	var bf = DataManager.get_current_battle_fight()
	var battleTactic = SceneManager.current_scene().battle_tactic
	var tactic = battleTactic.get_select_tactic_name()
	if tactic == "":
		FlowManager.add_flow("tactic_end")
		return
	if tactic == "主动技":
		FlowManager.add_flow("tactic_skills")
		return
	if tactic == "挑衅" and bf.solo_disabled():
		FlowManager.add_flow("tactic_end")
		return
	DataManager.set_env("值", tactic)
	var actorId = DataManager.get_env_int("当前武将")
	var wa = DataManager.get_war_actor(actorId)
	var enemy = wa.get_battle_enemy_war_actor()
	var cost = itactic.get_tactic_cost(wa, tactic)
	DataManager.set_env("战术消耗", cost)
	if not wa.consume_tactic_point(cost):
		LoadControl.set_view_model(100)
		return
	DataManager.set_env("结果", 1)
	SceneManager.current_scene().notice_tactic(wa, tactic)
	var nextFlow = "tactic_end";
	match tactic:
		"咒缚":
			if not Global.get_rate_result(itactic.get_stop_tactic_rate(actorId)):
				DataManager.set_env("结果", 0)
			nextFlow = "tactic_impact_0"
		"挑衅":
			var rate = enemy.get_solo_accept_rate(wa)
			if not Global.get_rate_result(rate):
				DataManager.set_env("结果", 0)
			nextFlow = "tactic_impact_1"
		"强弩":
			nextFlow = "tactic_impact_2"
		"士气向上":
			nextFlow = "tactic_impact_3"
		"火矢":
			nextFlow = "tactic_impact_4"
		_:
			#发动白兵主动技能
			if tactic.begins_with("<"):
				var skillName:String = tactic.replace("<","").replace(">","")
				if SkillHelper.player_choose_skill(actorId, skillName):
					return
	battleTactic.hide()
	# 触发我方发动战术事件，支持 flow，可以改变结果
	if SkillHelper.auto_trigger_skill(actorId, 30008, nextFlow):
		return
	if DataManager.get_env_int("战斗.战术接管") == 1:
		nextFlow = "tactic_end"
		DataManager.unset_env("战斗.战术接管")
	# 触发敌方发动战术事件，支持 flow，可以改变结果
	if SkillHelper.auto_trigger_skill(enemy.actorId, 30018, nextFlow):
		return
	if DataManager.get_env_int("战斗.战术接管") == 1:
		nextFlow = "tactic_end"
		DataManager.unset_env("战斗.战术接管")
	FlowManager.add_flow(nextFlow)
	return

#咒缚：结果
func tactic_impact_0():
	var actorId = DataManager.get_env_int("当前武将")
	var result = DataManager.get_env_int("结果")
	if result == 1:
		var bf = DataManager.get_current_battle_fight()
		var wa = DataManager.get_war_actor(actorId)
		var enemy = wa.get_battle_enemy_war_actor()
		DataManager.set_env("战术补充对话", "")
		DataManager.set_env("战术补充对话表情", 1)
		bf.set_buff(actorId, "咒缚", 3)
		var msg = "{0}暂时无法移动\n".format([enemy.get_name()])
		msg += DataManager.get_env_str("战术补充对话")
		var mood = DataManager.get_env_int("战术补充对话表情")
		SceneManager.show_confirm_dialog(msg, actorId, mood)
	else:
		SceneManager.show_confirm_dialog("咒止失败", actorId, 3)
	LoadControl.set_view_model(101)
	return

#挑衅：结果
func tactic_impact_1():
	# 需要考虑从技能进入此 flow 的情况，改回 view model
	LoadControl.view_model_name = view_model_name
	LoadControl.set_view_model(102)
	var actorId = DataManager.get_env_int("当前武将")
	var result = DataManager.get_env_int("结果")
	if result == 1:
		SceneManager.show_confirm_dialog("挑衅成功!", actorId, 1)
	else:
		var bf = DataManager.get_current_battle_fight()
		var wa = DataManager.get_war_actor(actorId)
		var enemy = wa.get_battle_enemy_war_actor()
		bf.reject_solo_request(enemy.actorId)
	return

#强弩
func tactic_impact_2():
	var actorId = DataManager.get_env_int("当前武将")
	var bf = DataManager.get_current_battle_fight()
	DataManager.set_env("战术补充对话", "")
	DataManager.set_env("战术补充对话表情", 1)
	bf.set_buff(actorId, "强弩", 3)
	var msg = "弓箭射程提升\n" + DataManager.get_env_str("战术补充对话")
	var mood = DataManager.get_env_int("战术补充对话表情")
	SceneManager.show_confirm_dialog(msg, actorId, mood)
	LoadControl.set_view_model(101)
	return

#士气向上
func tactic_impact_3():
	var actorId = DataManager.get_env_int("当前武将")
	var bf = DataManager.get_current_battle_fight()
	DataManager.set_env("战术补充对话", "")
	DataManager.set_env("战术补充对话表情", 1)
	bf.set_buff(actorId, "士气向上", 4)
	var msg = "全军士气提升\n" + DataManager.get_env_str("战术补充对话")
	var mood = DataManager.get_env_int("战术补充对话表情")
	SceneManager.show_confirm_dialog(msg, actorId, mood)
	LoadControl.set_view_model(101)
	return

#火矢
func tactic_impact_4():
	var actorId = DataManager.get_env_int("当前武将")
	var bf = DataManager.get_current_battle_fight()
	DataManager.set_env("战术补充对话", "")
	DataManager.set_env("战术补充对话表情", 1)
	bf.set_buff(actorId, "火矢", 4)
	var msg = "箭头已点上火\n" + DataManager.get_env_str("战术补充对话")
	var mood = DataManager.get_env_int("战术补充对话表情")
	SceneManager.show_confirm_dialog(msg, actorId, mood)
	LoadControl.set_view_model(101)
	return

func tactic_skills():
	var battleTactic = SceneManager.current_scene().battle_tactic
	battleTactic.show_active_skills()
	LoadControl.set_view_model(100)
	return
