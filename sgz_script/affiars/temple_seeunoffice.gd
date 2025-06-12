extends "affairs_base.gd"

#访隐
func _init() -> void:
	LoadControl.view_model_name = "内政-玩家-步骤";
	FlowManager.bind_import_flow("enter_seeunoffice_menu", self)
	
	FlowManager.bind_import_flow("seeunoffice_start", self)
	FlowManager.bind_import_flow("seeunoffice_1", self)
	FlowManager.bind_import_flow("seeunoffice_2", self)
	FlowManager.bind_import_flow("seeunoffice_3", self)
	FlowManager.bind_import_flow("seeunoffice_4", self)
	FlowManager.bind_import_flow("seeunoffice_5", self)
	
	FlowManager.bind_import_flow("find_actor_start", self)
	FlowManager.bind_import_flow("find_actor_1", self)
	FlowManager.bind_import_flow("find_actor_2", self)
	FlowManager.bind_import_flow("find_actor_3", self)

	FlowManager.bind_import_flow("find_equip_start", self)
	FlowManager.bind_import_flow("find_equip_type", self)
	FlowManager.bind_import_flow("find_equip_result", self)
	
#按键操控
func _input_key(delta: float):
	var scene_affiars:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var top = SceneManager.lsc_menu_top;
	var view_model = LoadControl.get_view_model();
	match view_model:
		170:
			#wait_for_confirmation("seeunoffice_1", "enter_temple_menu")
			wait_for_confirmation("seeunoffice_3", "enter_temple_menu")
		171: #命令书
			wait_for_yesno("seeunoffice_2", "enter_temple_menu")
		173: #访隐:选城
			var cityId = wait_for_choose_city(delta, "enter_seeunoffice_menu", clCity.all_city_ids())
			if cityId < 0:
				return
			DataManager.common_variable["目标城"] = cityId
			FlowManager.add_flow("seeunoffice_4")
		174:
			var values = DataManager.get_env_array("列表值")
			if not values.empty():
				var value:String = values[top.lsc.cursor_index]
				SceneManager.show_simply_actor_info(int(value.split('_')[1]))
			top.show();
			if(Input.is_action_just_pressed("ANALOG_UP")):
				top.lsc.move_up();
			if(Input.is_action_just_pressed("ANALOG_DOWN")):
				top.lsc.move_down();
			if(Input.is_action_just_pressed("ANALOG_LEFT")):
				top.lsc.move_left();
			if(Input.is_action_just_pressed("ANALOG_RIGHT")):
				top.lsc.move_right();
			if(Global.is_action_pressed_BY()):
				if(!SceneManager.dialog_msg_complete(false)):
					return;
				FlowManager.add_flow("seeunoffice_5");
		175:
			wait_for_yesno("seeunoffice_3", "city_enter_menu")
		240:
			wait_for_options(["seeunoffice_start", "find_actor_start", "find_equip_start"], "enter_temple_menu")
		241:
			if(Input.is_action_just_pressed("ANALOG_UP")):
				ActorHelper.next_char_option(-1)
			if(Input.is_action_just_pressed("ANALOG_DOWN")):
				ActorHelper.next_char_option(1)
			if(Input.is_action_just_pressed("ANALOG_LEFT")):
				ActorHelper.prev_idx()
			if(Input.is_action_just_pressed("ANALOG_RIGHT")):
				ActorHelper.next_idx()
			var chars = ActorHelper.get_selected_chars()
			if chars.length() >= 1:
				chars = chars[0] + " - " + chars.right(1)
			SceneManager.actor_dialog.rtlMessage.text = "要寻找「失踪人口」吗？\n方向键「输入」姓名：\n" + chars + " __"
			if Global.is_action_pressed_AX():
				if not SceneManager.dialog_msg_complete(true):
					return
				FlowManager.add_flow("find_actor_1")
			if Global.is_action_pressed_BY():
				if not SceneManager.dialog_msg_complete(false):
					return
				FlowManager.add_flow("enter_seeunoffice_menu")
		242:
			var nextFlow = "enter_seeunoffice_menu"
			if DataManager.is_test_player():
				nextFlow = "find_actor_2"
			wait_for_confirmation(nextFlow)
		243:
			if not DataManager.is_test_player():
				FlowManager.add_flow("enter_seeunoffice_menu")
			wait_for_yesno("find_actor_3", "enter_seeunoffice_menu")
		244:
			wait_for_confirmation("enter_seeunoffice_menu")
		250:
			if not wait_for_options([], "enter_seeunoffice_menu"):
				return
			var option = DataManager.get_env_str("菜单选项")
			LoadControl.set_view_model(-1)
			FlowManager.add_flow("find_equip_type")
			return
		251:
			if Input.is_action_just_pressed("ANALOG_UP"):
				ActorHelper.next_equip_option(-1)
			if Input.is_action_just_pressed("ANALOG_DOWN"):
				ActorHelper.next_equip_option(1)
			SceneManager.actor_dialog.rtlMessage.text = ActorHelper.show_equip_message()
			if Global.is_action_pressed_AX():
				if not SceneManager.dialog_msg_complete(true):
					return
				FlowManager.add_flow("find_equip_result")
			if Global.is_action_pressed_BY():
				if not SceneManager.dialog_msg_complete(false):
					return
				FlowManager.add_flow("find_equip_start")
		252:
			wait_for_confirmation("find_equip_type")
	return

#----------访隐--------------------
func enter_seeunoffice_menu() -> void:
	SceneManager.current_scene().cursor.hide()
	DataManager.twinkle_citys = [DataManager.player_choose_city]
	var msg = "想看哪个？"
	var options = ["城市在野","武将寻踪","装备情报"]
	SceneManager.bind_bottom_menu(msg, options, 1)
	LoadControl.set_view_model(240)
	return

#---------------显示在野-------------------
#访隐
func seeunoffice_start():
	LoadControl.set_view_model(170);
	#SceneManager.show_confirm_dialog("此功能用于查看城市\n在野武将及出仕年份\n是否继续？");
	SceneManager.show_confirm_dialog("此功能用于查看城市\n在野武将及出仕年份");
	SceneManager.show_cityInfo(true);
	return
	
func seeunoffice_1():
	LoadControl.set_view_model(171);
	#命令书确认
	SceneManager.show_yn_dialog("消耗1枚命令书可否");
	SceneManager.show_cityInfo(true);

#命令书消耗动画
func seeunoffice_2():
	LoadControl.set_view_model(172);
	SceneManager.dialog_use_orderbook_animation("seeunoffice_3");

func seeunoffice_3():
	LoadControl.set_view_model(173);
	SceneManager.clear_bottom();
	DataManager.twinkle_citys.clear();
	var scene_affiars:Control = SceneManager.current_scene();
	var vstate_controlNo = DataManager.get_current_control_sort()
	var player:Player = DataManager.players[vstate_controlNo];
	scene_affiars.cursor.show();
	scene_affiars.set_city_cursor_position(DataManager.player_choose_city);
	SceneManager.show_unconfirm_dialog("查看哪座城池的在野武将？");

func seeunoffice_4():
	LoadControl.set_view_model(174);
	SceneManager.current_scene().cursor.hide();
	var targetCityId = DataManager.get_env_int("目标城")
	var targetCity = clCity.city(targetCityId)
	var words = {}
	var values = []
	for dic in DataManager.citys_unoffice:
		if int(dic["城池"]) != targetCityId:
			continue
		var actorId = int(dic["武将"])
		var actor = ActorHelper.actor(actorId)
		if not actor.is_status_unofficed():
			continue
		var state = "√";
		var appearYear = actor.get_appear_year(int(dic["登场年"]))
		if appearYear > DataManager.year:
			state = "—";
		var key = "{0}_{1}".format([dic["登场年"], actorId])
		values.append(key)
		words[key] = "{0} {1} {2}".format([dic["登场年"], actor.get_name(), state])
	values.sort();
	var items = []
	for val in values:
		items.append(words[val])

	SceneManager.hide_all_tool();
	if not values.empty():
		SceneManager.show_simply_actor_info(int(values[0].split('_')[1]))
	SceneManager.lsc_menu_top.lsc.columns = 2
	SceneManager.lsc_menu_top.lsc.items = items
	DataManager.set_env("列表值", values)
	
	SceneManager.lsc_menu_top.set_lsc()
	SceneManager.lsc_menu_top.lsc._set_data(30)
	SceneManager.lsc_menu_top.show()
	return

func seeunoffice_5():
	SceneManager.show_yn_dialog("是否查看其他城市\n在野武将？")
	LoadControl.set_view_model(175)
	return

#---------------武将寻踪-------------------
func find_actor_start():
	LoadControl.set_view_model(241);
	SceneManager.show_cityInfo(true);
	SceneManager.show_confirm_dialog("要寻找「失踪人口」吗？\n方向键「输入」姓名：\n" + ActorHelper.get_selected_chars() + " __");
	return
	
func find_actor_1():
	var name = ActorHelper.get_selected_chars()
	var msgs = ActorHelper.get_actor_clue(name)[0]
	SceneManager.show_confirm_dialog("\n".join(msgs))
	LoadControl.set_view_model(242)
	return

func find_actor_2():
	var name = ActorHelper.get_selected_chars()
	var actorId = ActorHelper.get_actor_clue(name)[1]
	var city = clCity.city(DataManager.player_choose_city)
	if actorId < 0:
		SceneManager.show_confirm_dialog("未找到" + name.substr(1))
		LoadControl.set_view_model(244)
		return
	DataManager.player_choose_actor = actorId
	var actor = ActorHelper.actor(DataManager.player_choose_actor)
	var msg ="是否将{0}招致麾下？"
	if actor.actorId in city.get_actor_ids():
		msg = "{0}已在城中\n是否设定为满级？"
	msg = msg.format([actor.get_name()])
	SceneManager.show_yn_dialog(msg)
	LoadControl.set_view_model(243)
	return

func find_actor_3():
	var actor = ActorHelper.actor(DataManager.player_choose_actor)
	var city = clCity.city(DataManager.player_choose_city)
	var msg = "已将{0}招致麾下"
	if actor.actorId in city.get_actor_ids():
		actor.set_exp(99999)
		actor.check_levelup()
		msg = "已将{0}升至8级"
	else:
		actor.set_status_officed()
		clCity.move_out(actor.actorId)
		clCity.move_to(actor.actorId, city.ID)
	msg = msg.format([actor.get_name()])
	SceneManager.show_confirm_dialog(msg)
	LoadControl.set_view_model(244)
	return

#---------------装备情报-------------------
func find_equip_start() -> void:
	SceneManager.show_cityInfo(false)
	var msg = "访隐何种装备？"
	var options = ["武器", "防具", "道具", "坐骑"]
	SceneManager.bind_bottom_menu(msg, options, 2)
	LoadControl.set_view_model(250)
	return

func find_equip_type():
	var type = DataManager.get_env_str("菜单选项")
	SceneManager.show_cityInfo(false)
	SceneManager.show_confirm_dialog(ActorHelper.show_equip_message(0, type))
	LoadControl.set_view_model(251)
	return

func find_equip_result():
	var name = ActorHelper.get_selected_equip_name()
	SceneManager.show_confirm_dialog(ActorHelper.get_equip_clue(name))
	LoadControl.set_view_model(252)
	return
