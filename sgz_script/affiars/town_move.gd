extends "affairs_base.gd"

#移动
func _init() -> void:
	LoadControl.view_model_name = "内政-玩家-步骤";
	FlowManager.bind_signal_method("move_start",self,"move_start");
	FlowManager.bind_signal_method("move_2",self,"move_2");
	FlowManager.bind_signal_method("move_3",self,"move_3");
	FlowManager.bind_signal_method("move_4",self,"move_4");
	FlowManager.bind_signal_method("move_5",self,"move_5");
	FlowManager.bind_signal_method("move_6",self,"move_6");
	return

#按键操控
func _input_key(delta: float):
	var scene_affiars:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	match view_model:
		121: #移动流程：选择城市
			var fromCity = clCity.city(DataManager.player_choose_city)
			var connectedCities = []
			var availableCities = fromCity.get_connected_city_ids()
			if not SkillRangeBuff.find_for_vstate("跨城调将", fromCity.get_vstate_id()).empty():
				availableCities = clCity.all_city_ids()
			for cityId in availableCities:
				if clCity.city(cityId).get_vstate_id() in [-1, fromCity.get_vstate_id()]:
					connectedCities.append(cityId)
			var cityId = wait_for_choose_city(delta, "enter_town_menu", connectedCities)
			if cityId < 0:
				return
			if cityId == fromCity.ID:
				SceneManager.show_unconfirm_dialog("本城何须调动奔波？")
				return
			var city = clCity.city(cityId)
			# 判断相连
			if not cityId in fromCity.get_connected_city_ids():
				if SkillRangeBuff.find_for_vstate("跨城调将", fromCity.get_vstate_id()).empty():
					SceneManager.show_unconfirm_dialog("无法移动至该城")
					return
			# 判断归属
			if not city.get_vstate_id() in [-1, fromCity.get_vstate_id()]:
				SceneManager.show_unconfirm_dialog("无法移动至该城")
				return
			
			DataManager.set_env("目标城", cityId)
			scene_affiars.reset_view()
			FlowManager.add_flow("move_2")
		122: #移动流程：选择武将
			if not wait_for_choose_actor("enter_town_menu"):
				return
			var idx = SceneManager.actorlist.get_select_actor()
			var actors = SceneManager.actorlist.get_picked_actors()
			if idx >= 0:
				SceneManager.actorlist.set_actor_picked(idx)
				return
			if actors.empty():
				return
			DataManager.set_env("内政.移动武将", actors)
			LoadControl.set_view_model(-1)
			FlowManager.add_flow("move_3")
		123: #确认放弃城市
			wait_for_yesno("move_4", "enter_town_menu")
		124: #命令书
			wait_for_yesno("move_5", "enter_town_menu")
	return

#武将移动：选城(121)
func move_start():
	var scene_affiars:Control = SceneManager.current_scene();
	var vstate_controlNo = DataManager.get_current_control_sort()
	var player:Player = DataManager.players[vstate_controlNo];
	scene_affiars.cursor.show()
	var cityId = DataManager.player_choose_city
	scene_affiars.set_city_cursor_position(cityId)
	SceneManager.clear_bottom()
	DataManager.twinkle_citys.clear()
	SceneManager.show_unconfirm_dialog("向哪座城池移动？\n请指定")
	scene_affiars.show_movable_city_lines(cityId)
	LoadControl.set_view_model(121)
	return

#武将移动：选人
func move_2():
	LoadControl.set_view_model(122);
	var scene_affiars:Control = SceneManager.current_scene();
	scene_affiars.cursor.hide();
	var city = clCity.city(DataManager.player_choose_city);
	SceneManager.show_actorlist_army(city.get_actor_ids(), true, "派遣何人？请指定", false);
	return

#武将移动：判断空城
func move_3():
	var fromCity = clCity.city(DataManager.player_choose_city)
	var sendActors = DataManager.get_env_int_array("内政.移动武将")
	if fromCity.get_actor_ids().size() != sendActors.size():
		FlowManager.add_flow("move_4")
		return
	SceneManager.show_yn_dialog("是否放弃此城？")
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(123)
	return

#武将移动：消耗命令书
func move_4():
	#命令书确认
	SceneManager.show_yn_dialog("消耗1枚命令书可否")
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(124)
	return

#武将移动：命令书消耗动画
func move_5():
	SceneManager.dialog_use_orderbook_animation("move_6")
	return

#武将移动：动画
func move_6():
	var targetCityId = DataManager.get_env_int("目标城")
	var targetCity = clCity.city(targetCityId)
	var fromCity = clCity.city(DataManager.player_choose_city)
	var sendActors = DataManager.get_env_int_array("内政.移动武将")

	DataManager.set_env("内政.命令", "移动")
	for actorId in sendActors:
		clCity.move_to(actorId, targetCity.ID)
		# 不支持流程
		SkillHelper.auto_trigger_skill(actorId, 10012, "")
	targetCity.change_vstate(fromCity.get_vstate_id())
	if fromCity.get_actor_ids().empty():
		fromCity.change_vstate(-1)
	DataManager.twinkle_citys = [fromCity.ID, targetCity.ID]
	var msg = "遵命，马上就去"
	DataManager.set_env("对话", msg)
	SceneManager.play_affiars_animation(
		"Town_Move", "confirm_to_ready", false,
		msg, sendActors[0], 2
	)
	return
