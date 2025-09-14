extends "affairs_base.gd"

#侦察
func _init() -> void:
	LoadControl.view_model_name = "内政-玩家-步骤"
	FlowManager.bind_signal_method("inspect_start", self)
	FlowManager.bind_signal_method("inspect_1", self)
	FlowManager.bind_signal_method("inspect_2", self)
	FlowManager.bind_signal_method("inspect_3", self)
	FlowManager.bind_signal_method("inspect_4", self)
	FlowManager.bind_signal_method("inspect_more", self)
	FlowManager.bind_signal_method("inspect_map", self)
	FlowManager.bind_signal_method("inspect_spy", self)
	FlowManager.bind_signal_method("inspect_spy_confirmed", self)

	FlowManager.clear_pre_history.append("inspect_3")

	return


#按键操控
func _input_key(delta: float):
	var scene_affiars:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	match view_model:
		230:
			wait_for_yesno("inspect_1", "enter_barrack_menu")
		232:
			var cityId = wait_for_choose_city(delta, "", clCity.all_city_ids())
			if cityId < 0:
				return
			DataManager.set_env("目标城", cityId)
			FlowManager.add_flow("inspect_3")
		233:
			var cityId = DataManager.get_env_int("目标城")
			if Input.is_action_pressed("ANALOG_UP"):
				SceneManager.actor_info.prev_actor()
			if Input.is_action_pressed("ANALOG_DOWN"):
				SceneManager.actor_info.next_actor()
			if Global.is_action_pressed_AX():
				if DataManager.cityInfo_type == 0:
					DataManager.cityInfo_type = 1
				else:
					DataManager.cityInfo_type = 0
				SceneManager.show_cityInfo(true, cityId)
			if Global.is_action_pressed_BY():
				FlowManager.add_flow("inspect_4")
				return
			if Input.is_action_just_pressed("EMU_START"):
				FlowManager.add_flow("inspect_more")
				return
		234:
			wait_for_yesno("inspect_2", "city_enter_menu")
		235:
			var flows = ["inspect_map", "inspect_spy"]
			wait_for_options(flows, "inspect_3")
		236:
			wait_for_yesno("inspect_spy_confirmed", "inspect_more")
		239:
			wait_for_confirmation("city_enter_menu")
	return

#消耗命令书
func inspect_start():
	#命令书确认
	SceneManager.show_yn_dialog("消耗1枚命令书可否")
	SceneManager.actor_dialog.lsc.cursor_index = 1
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(230)
	return

#命令书动画
func inspect_1():
	SceneManager.dialog_use_orderbook_animation("inspect_2")
	DataManager.set_env("目标城", DataManager.player_choose_city)
	LoadControl.set_view_model(231)
	return

#选择侦察城池
func inspect_2():
	SceneManager.clear_bottom()
	DataManager.twinkle_citys.clear()
	var scene_affiars:Control = SceneManager.current_scene()
	var target_cityId = DataManager.get_env_int("目标城")
	scene_affiars.set_city_cursor_position(target_cityId)
	scene_affiars.cursor.show()
	scene_affiars.inspecting = true
	var vstate_controlNo = DataManager.get_current_control_sort()
	var player:Player = DataManager.players[vstate_controlNo]
	var msg = "侦察哪座城池？\n请指定"
	SceneManager.show_unconfirm_dialog(msg, player.actorId)
	LoadControl.set_view_model(232)
	return

#显示城池信息
func inspect_3():
	var scene_affiars:Control = SceneManager.current_scene()
	scene_affiars.cursor.hide()
	DataManager.cityInfo_type = 0;#默认显示0号信息
	
	var targetCity = clCity.city(DataManager.get_env_int("目标城"))
	DataManager.twinkle_citys = [targetCity.ID]
	var actors = targetCity.get_actor_ids()
	if actors.empty():
		SceneManager.show_unconfirm_dialog("空城")
	else:
		SceneManager.show_actor_info_list(actors)
	SceneManager.show_cityInfo(true, targetCity.ID)
	SceneManager.show_special_tips("「开始」键选择进一步侦察操作", 12)
	LoadControl.set_view_model(233)
	return

#询问是否继续
func inspect_4():
	SceneManager.reset_tips()
	SceneManager.show_yn_dialog("是否还侦察其他城市？")
	LoadControl.set_view_model(234)
	return

# 进一步侦察操作
# @since 2.23
func inspect_more() -> void:
	var targetCity = clCity.city(DataManager.get_env_int("目标城"))
	SceneManager.reset_tips()
	SceneManager.actor_info.hide()
	var options = ["查看地形", "谍报工作"]
	SceneManager.bind_bottom_menu("可进一步侦察", options, 1)
	DataManager.cityInfo_type = 0
	SceneManager.show_cityInfo(true, targetCity.ID)
	LoadControl.set_view_model(235)
	return

# 查看地图
func inspect_map() -> void:
	var targetCityId = DataManager.get_env_int("目标城")
	var wf = DataManager.new_war_fight(DataManager.player_choose_city, targetCityId)
	wf.init_war()
	LoadControl.end_script()
	FlowManager.clear_bind_method()

	FlowManager.add_flow("go_to_scene|res://scene/scene_war/scene_war.tscn")
	FlowManager.add_flow("war_map_nav_start")
	return

# 谍报工作
func inspect_spy() -> void:
	var vstate_controlNo = DataManager.get_current_control_sort()
	var player:Player = DataManager.players[vstate_controlNo]
	var cityId = DataManager.get_env_int("目标城")
	var msg = "进行谍报，将结束侦察命令\n预期在一年内，可第一时间探知{0}动向，可否？".format([
		clCity.city(cityId).get_full_name(),
	])
	SceneManager.show_yn_dialog(msg, player.actorId)
	LoadControl.set_view_model(236)
	return

# 谍报工作确认
func inspect_spy_confirmed() -> void:
	var vstate_controlNo = DataManager.get_current_control_sort()
	var player:Player = DataManager.players[vstate_controlNo]
	var cityId = DataManager.get_env_int("目标城")
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no]
	clCity.city(cityId).mark_inspected(vstateId)
	var msg = "已在{0}埋伏人手\n有情况将即时回报\n侦察命令结束".format([
		clCity.city(cityId).get_full_name(),
	])
	SceneManager.show_confirm_dialog(msg, player.actorId, 1)
	LoadControl.set_view_model(239)
	return
