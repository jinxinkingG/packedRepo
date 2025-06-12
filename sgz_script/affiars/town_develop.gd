extends "affairs_base.gd"

#开发
func _init() -> void:
	LoadControl.view_model_name = "内政-玩家-步骤";
	FlowManager.bind_import_flow("develop_menu", self)
	FlowManager.bind_signal_method("develop_start", self)
	FlowManager.bind_signal_method("develop_1", self)
	FlowManager.bind_signal_method("develop_2", self)
	FlowManager.bind_signal_method("develop_3", self)
	FlowManager.bind_signal_method("develop_4", self)
	FlowManager.bind_signal_method("develop_5", self)
	FlowManager.bind_signal_method("develop_6", self)
	FlowManager.bind_signal_method("develop_7", self)
	FlowManager.bind_signal_method("develop_done_trigger", self)
	FlowManager.bind_signal_method("develop_done_trigger_end", self)
	FlowManager.bind_signal_method("develop_done", self)
	FlowManager.bind_signal_method("develop_result_message", self)

#按键操控
func _input_key(delta: float):
	match LoadControl.get_view_model():
		110: #选择开发选项（土地、产业、人口）
			if not wait_for_options(["develop_1", "develop_1", "develop_1"], "enter_town_menu"):
				return
		111: #开发流程：选择武将
			if not wait_for_choose_actor("develop_menu"):
				return
			DataManager.player_choose_actor = SceneManager.actorlist.get_select_actor();
			if SkillHelper.auto_trigger_skill(DataManager.player_choose_actor, 10008, ""):
				return;
			LoadControl.set_view_model(-1)
			FlowManager.add_flow("develop_2")
		113: #开发流程：确认对话
			wait_for_confirmation("develop_4", "develop_start")
		114: #开发流程：命令书
			wait_for_yesno("develop_5", "enter_town_menu")
		116: #开发流程：动画和初步信息确认
			wait_for_confirmation("develop_7")
		117: #开发完成
			wait_for_confirmation("develop_result_message")
	return

#开发菜单
func develop_menu():
	var cmd = DataManager.get_current_develop_command()
	SceneManager.current_scene().cursor.hide()
	DataManager.twinkle_citys = [DataManager.player_choose_city]
	SceneManager.hide_all_tool()
	var devOptions = ["土地", "产业", "人口"]
	var items = ["土地开垦","鼓励工商","市集开发"]
	DataManager.set_env("列表值", items)
	SceneManager.lsc_menu.lsc.columns = 1
	SceneManager.lsc_menu.lsc.items = items
	SceneManager.lsc_menu.set_lsc()
	SceneManager.lsc_menu.lsc._set_data()
	SceneManager.lsc_menu.show_msg("请大人施政")
	SceneManager.lsc_menu.show_orderbook(true)
	DataManager.cityInfo_type = 1
	SceneManager.show_cityInfo(true)
	var city = clCity.city(DataManager.player_choose_city)
	var devIndex = devOptions.find(cmd.type)
	if devIndex < 0:
		devIndex = 0
	if devIndex == 0 and city.get_land() >= 999:
		devIndex = 1
	if devIndex == 1 and city.get_eco() >= 999:
		devIndex = 2
	SceneManager.lsc_menu.lsc.cursor_index = devIndex
	SceneManager.lsc_menu.show()
	LoadControl.set_view_model(110)
	return

func develop_1():
	var city = clCity.city(int(DataManager.player_choose_city))
	var devOptions = ["土地", "产业", "人口"]
	var devLimits = [999, 999, 999900]
	var devMaxNotices = ["开垦土地", "发展产业", "开发人口"]
	var idx = SceneManager.lsc_menu.lsc.cursor_index
	if idx < 0 or idx >= devOptions.size():
		LoadControl.set_view_model(110)
		return
	var devOption = devOptions[idx]
	if int(city.get_property(devOption)) >= devLimits[idx]:
		SceneManager.lsc_menu.show_msg("已无需" + devMaxNotices[idx])
		LoadControl.set_view_model(110)
		return
	var cmd = DataManager.get_current_develop_command()
	cmd.type = devOptions[idx]
	FlowManager.add_flow("develop_start")
	return

#城镇开发：选人(111)
func develop_start():
	SceneManager.current_scene().cursor.hide();
	DataManager.twinkle_citys = [DataManager.player_choose_city]
	var city = clCity.city(DataManager.player_choose_city)
	var cmd = DataManager.get_current_develop_command()
	var actorIds = city.get_actor_ids()
	SceneManager.show_actorlist_develop(actorIds, false, "派遣何人？请指定")
	var lastSelectedIdx = actorIds.find(cmd.lastActionId)
	if lastSelectedIdx >= 0:
		SceneManager.actorlist.move_to(lastSelectedIdx)
	LoadControl.set_view_model(111)
	return

#城镇开发：计算金额
func develop_2():
	var cmd = DataManager.get_current_develop_command()
	cmd = DataManager.new_develop_command(cmd.type, DataManager.player_choose_actor, DataManager.player_choose_city)
	cmd.lastActionId = DataManager.player_choose_actor
	cmd.decide_cost()

	var developSetting = StaticManager.get_develop_setting()
	var develop_gif_groups = developSetting["develop_gif_groups"]
	var develop_ask_dialog = developSetting["develop_ask_dialog"]
	var animation_name = developSetting["animation_name"]
	var dialog_id = develop_gif_groups[cmd.type][cmd.devLevel][cmd.devRnd]
	while dialog_id == -1:
		var r = Global.get_random(0, 4)
		dialog_id = develop_gif_groups[cmd.type][cmd.devLevel][r]
	#对话
	var dialog_text = develop_ask_dialog[cmd.type][dialog_id]
	dialog_text = dialog_text.replace("@cost", str(cmd.get_real_cost()))
	DataManager.set_env("对话", dialog_text)
	DataManager.set_env("动画", animation_name[cmd.type][dialog_id])
	FlowManager.add_flow("develop_3")
	LoadControl.set_view_model(112)
	return

#城镇开发：对话提示金额
func develop_3():
	# 清除多动造成的历史巨长问题
	FlowManager.flows_history_list.clear()
	FlowManager.flows_history_list.append("develop_3")
	var cmd = DataManager.get_current_develop_command()
	var dialog = DataManager.get_env_str("对话")
	SceneManager.show_confirm_dialog(dialog, cmd.actionId)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(113)
	return

#城镇开发：命令书
func develop_4():
	var cmd = DataManager.get_current_develop_command()
	var city = clCity.city(DataManager.player_choose_city)
	if cmd.get_real_cost() > cmd.city().get_gold():
		LoadControl._affiars_error("如今城内并无足够金钱\n请下达其他命令", cmd.actionId, 3)
		return

	#命令书确认
	SceneManager.show_yn_dialog("消耗1枚命令书可否")
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(114)
	return

#城镇开发：命令书消耗动画
func develop_5():
	var cmd = DataManager.get_current_develop_command()
	cmd.execute()
	SceneManager.dialog_use_orderbook_animation("develop_6")
	LoadControl.set_view_model(115)
	return

#动画
func develop_6():
	var cmd = DataManager.get_current_develop_command()
	var anim = DataManager.get_env_str("动画")
	SceneManager.play_affiars_animation(anim, "develop_7", false, cmd.get_notice(), cmd.actionId, 1)
	LoadControl.set_view_model(116)
	return

func develop_7():
	SceneManager.cleanup_animations()
	var cmd = DataManager.get_current_develop_command()
	var msgs = cmd.get_result_messages()
	DataManager.set_env("内政.对话PENDING", [])
	if msgs.size() > 3:
		DataManager.set_env("内政.对话PENDING", msgs.slice(3, msgs.size() - 1))
		msgs = msgs.slice(0, 2)
	SceneManager.show_confirm_dialog("\n".join(msgs), cmd.actionId, 1)
	SceneManager.dialog_msg_complete(true)
	DataManager.cityInfo_type = 1
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(117)
	return

func develop_result_message():
	var cmd = DataManager.get_current_develop_command()
	var msgs = DataManager.get_env_array("内政.对话PENDING")
	if msgs.empty():
		FlowManager.add_flow("develop_done_trigger")
		return
	DataManager.set_env("内政.对话PENDING", [])
	if msgs.size() > 3:
		DataManager.set_env("内政.对话PENDING", msgs.slice(3, msgs.size() - 1))
		msgs = msgs.slice(0, 2)
	SceneManager.show_confirm_dialog("\n".join(msgs), cmd.actionId, 1)
	SceneManager.dialog_msg_complete(true)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(117)
	return

func develop_done_trigger():
	var cmd = DataManager.get_current_develop_command()
	if cmd.actionId != DataManager.player_choose_actor:
		# 非正常开启的内政行动，可能是技能强行启动
		FlowManager.add_flow("develop_done")
		return
	OrderHistory.record_order(cmd.city().get_vstate_id(), "开发", cmd.actionId)
	DataManager.set_env("内政.命令", "开发")
	if SkillHelper.auto_trigger_skill(cmd.actionId, 10012, "develop_done"):
		return
	FlowManager.add_flow("develop_done")
	return

func develop_done():
	FlowManager.add_flow("city_enter_menu")
	return
