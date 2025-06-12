extends "affairs_base.gd"

#侦察
func _init() -> void:
	LoadControl.view_model_name = "内政-玩家-步骤";
	FlowManager.bind_signal_method("inspect_start", self)
	FlowManager.bind_signal_method("inspect_1", self)
	FlowManager.bind_signal_method("inspect_2", self)
	FlowManager.bind_signal_method("inspect_3", self)
	FlowManager.bind_signal_method("inspect_4", self)
	
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
			DataManager.common_variable["目标城"] = cityId
			FlowManager.add_flow("inspect_3")
		233:
			if(Input.is_action_pressed("ANALOG_UP")):
				SceneManager.actor_info.prev_actor();
			if(Input.is_action_pressed("ANALOG_DOWN")):
				SceneManager.actor_info.next_actor();
			if(Global.is_action_pressed_AX()):
				if(DataManager.cityInfo_type==0):
					DataManager.cityInfo_type=1;
				else:
					DataManager.cityInfo_type=0;
				SceneManager.show_cityInfo(true,DataManager.common_variable["目标城"]);
			if(Global.is_action_pressed_BY()):
				FlowManager.add_flow("inspect_4");
		234:
			wait_for_yesno("inspect_2", "city_enter_menu")
	return

#消耗命令书
func inspect_start():
	#命令书确认
	SceneManager.show_yn_dialog("消耗1枚命令书可否");
	SceneManager.actor_dialog.lsc.cursor_index = 1
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(230)
	return

#命令书动画
func inspect_1():
	LoadControl.set_view_model(231);
	SceneManager.dialog_use_orderbook_animation("inspect_2");
	DataManager.common_variable["目标城"] = DataManager.player_choose_city;
	

#选择侦察城池
func inspect_2():
	LoadControl.set_view_model(232);
	SceneManager.clear_bottom();
	DataManager.twinkle_citys.clear();
	var scene_affiars:Control = SceneManager.current_scene();
	var target_cityId = int(DataManager.common_variable["目标城"]);
	scene_affiars.set_city_cursor_position(target_cityId);
	scene_affiars.cursor.show();
	var vstate_controlNo = DataManager.get_current_control_sort()
	var player:Player = DataManager.players[vstate_controlNo];
	SceneManager.show_unconfirm_dialog("侦察哪座城池？\n请指定");

#显示城池信息
func inspect_3():
	LoadControl.set_view_model(233);
	var scene_affiars:Control = SceneManager.current_scene();
	scene_affiars.cursor.hide();
	DataManager.cityInfo_type = 0;#默认显示0号信息
	
	var targetCity = clCity.city(int(DataManager.common_variable["目标城"]))
	DataManager.twinkle_citys = [targetCity.ID]
	var actors = targetCity.get_actor_ids()
	if actors.empty():
		SceneManager.show_unconfirm_dialog("空城");
	else:
		SceneManager.show_actor_info_list(actors);
	SceneManager.show_cityInfo(true, targetCity.ID)

#询问是否继续
func inspect_4():
	LoadControl.set_view_model(234);
	SceneManager.show_yn_dialog("是否还侦察其他城市？");
	DataManager.cityInfo_type = 2;

