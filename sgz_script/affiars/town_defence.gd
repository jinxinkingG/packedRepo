extends "affairs_base.gd"

#防灾
func _init() -> void:
	LoadControl.view_model_name = "内政-玩家-步骤";
	FlowManager.bind_signal_method("defence_start", self)
	FlowManager.bind_signal_method("defence_2", self)
	FlowManager.bind_signal_method("defence_3", self)
	FlowManager.bind_signal_method("defence_4", self)
	FlowManager.bind_signal_method("defence_5", self)
	FlowManager.bind_signal_method("defence_6", self)
	FlowManager.bind_signal_method("defence_7", self)
	FlowManager.bind_signal_method("defence_result_message", self)
	FlowManager.bind_signal_method("defence_done_trigger", self)
	FlowManager.bind_signal_method("defence_done", self)
	return

#按键操控
func _input_key(delta: float):
	var scene_affiars:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	match view_model:
		141: #防灾流程：选择武将
			if not wait_for_choose_actor("enter_town_menu"):
				return
			LoadControl.set_view_model(-1)
			DataManager.player_choose_actor = SceneManager.actorlist.get_select_actor()
			if SkillHelper.auto_trigger_skill(DataManager.player_choose_actor, 10008, ""):
				return
			FlowManager.add_flow("defence_2")
		143: #防灾流程：确认对话
			wait_for_confirmation("defence_4", "defence_start")
		144: #防灾流程：命令书
			wait_for_yesno("defence_5", "enter_town_menu")
		147: #防灾完成
			wait_for_confirmation("defence_result_message")
	return

#防灾：选人(141)
func defence_start():
	var cmd = DataManager.get_current_develop_command()
	var city = clCity.city(DataManager.player_choose_city)
	if city.get_defence() >= 99:
		LoadControl._affiars_error("已无需发展防灾")
		return;
	SceneManager.current_scene().cursor.hide()
	DataManager.twinkle_citys = [city.ID]
	var actorIds = city.get_actor_ids()
	SceneManager.show_actorlist_develop(actorIds, false, "派遣何人？请指定")
	var lastSelectedIdx = actorIds.find(cmd.actionId)
	if lastSelectedIdx >= 0:
		SceneManager.actorlist.move_to(lastSelectedIdx)
	LoadControl.set_view_model(141)
	return

#防灾：计算金额
func defence_2():
	# 防灾不改变上次开发的武将
	var cmd = DataManager.get_current_develop_command()
	var lastActionId = cmd.lastActionId
	cmd = DataManager.new_develop_command("防灾", DataManager.player_choose_actor, DataManager.player_choose_city)
	# 继承上次开发的武将
	cmd.lastActionId = lastActionId
	cmd.decide_cost()
	FlowManager.add_flow("defence_3")
	return

#防灾：对话提示金额
func defence_3():
	var cmd = DataManager.get_current_develop_command()
	var msg = "为预防灾害\n需{0}两金".format([cmd.get_real_cost()])
	SceneManager.show_confirm_dialog(msg, cmd.actionId)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(143)
	return

#防灾：命令书
func defence_4():
	var cmd = DataManager.get_current_develop_command()
	if cmd.get_real_cost() > cmd.city().get_gold():
		LoadControl._affiars_error("如今城内并无足够金钱\n请下达其他命令", cmd.actionId, 3)
		return
	SceneManager.show_yn_dialog("消耗1枚命令书可否")
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(144)
	return

#防灾：命令书消耗动画
func defence_5():
	var cmd = DataManager.get_current_develop_command()
	cmd.execute()
	SceneManager.dialog_use_orderbook_animation("defence_6")
	return

#动画
func defence_6():
	var cmd = DataManager.get_current_develop_command()
	SceneManager.show_unconfirm_dialog(cmd.get_notice())
	SceneManager.dialog_msg_complete(true)
	SceneManager.play_affiars_animation("Town_Develop_Farm_00", "defence_7")
	LoadControl.set_view_model(146)
	return

func defence_7():
	var cmd = DataManager.get_current_develop_command()
	var msgs = cmd.get_result_messages()
	DataManager.set_env("内政.对话PENDING", [])
	if msgs.size() > 3:
		DataManager.set_env("内政.对话PENDING", msgs.slice(3, msgs.size() - 1))
		msgs = msgs.slice(0, 2)
	SceneManager.show_confirm_dialog("\n".join(msgs), cmd.actionId, 1)
	SceneManager.dialog_msg_complete(true)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(147)
	return

func defence_result_message():
	var cmd = DataManager.get_current_develop_command()
	var msgs = DataManager.get_env_array("内政.对话PENDING")
	if msgs.empty():
		FlowManager.add_flow("defence_done_trigger")
		return
	DataManager.set_env("内政.对话PENDING", [])
	if msgs.size() > 3:
		DataManager.set_env("内政.对话PENDING", msgs.slice(3, msgs.size() - 1))
		msgs = msgs.slice(0, 2)
	SceneManager.show_confirm_dialog("\n".join(msgs), cmd.actionId, 1)
	SceneManager.dialog_msg_complete(true)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(147)
	return

func defence_done_trigger():
	var cmd = DataManager.get_current_develop_command()
	OrderHistory.record_order(cmd.city().get_vstate_id(), "防灾", cmd.actionId)
	DataManager.set_env("内政.命令", "防灾")
	if SkillHelper.auto_trigger_skill(cmd.actionId, 10012, "defence_done"):
		return
	FlowManager.add_flow("defence_done")
	return

func defence_done():
	FlowManager.add_flow("city_enter_menu")
	return
