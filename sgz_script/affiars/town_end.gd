extends "affairs_base.gd"

#结束
func _init() -> void:
	LoadControl.view_model_name = "内政-玩家-步骤";
	FlowManager.bind_signal_method("endmonth_start",self,"endmonth_start");
	FlowManager.bind_signal_method("endmonth_2",self,"endmonth_2");
	FlowManager.bind_signal_method("endmonth_3",self,"endmonth_3");
	FlowManager.bind_signal_method("endmonth_4",self,"endmonth_4");
	FlowManager.bind_signal_method("endmonth_5",self,"endmonth_5");
	return

#按键操控
func _input_key(delta: float):
	var scene_affiars:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	match view_model:
		171:
			wait_for_confirmation("endmonth_2", "city_enter_menu")
		172:
			wait_for_confirmation("endmonth_3", "city_enter_menu")
		173:#命令书
			wait_for_yesno("endmonth_4", "city_enter_menu")
		175:
			wait_for_confirmation()
	return

#对话1
func endmonth_start():
	LoadControl.set_view_model(171);
	SceneManager.show_confirm_dialog("即将结束本月行动\n清空所有命令书");
	SceneManager.show_cityInfo(true);
	
#对话2
func endmonth_2():
	LoadControl.set_view_model(172);
	SceneManager.show_confirm_dialog("如果想要存档\n请使用即时存档");
	SceneManager.show_cityInfo(true);

#命令书
func endmonth_3():
	#命令书确认
	SceneManager.show_yn_dialog("确定结束本月吗?")
	SceneManager.actor_dialog.lsc.cursor_index = 1
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(173)
	return

#命令书消耗动画
func endmonth_4():
	LoadControl.set_view_model(174);
	SceneManager.dialog_use_orderbook_animation("endmonth_5",255);


func endmonth_5():
	LoadControl.set_view_model(175);
	SceneManager.show_confirm_dialog("已结束本月");
