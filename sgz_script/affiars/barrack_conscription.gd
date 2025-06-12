extends "affairs_base.gd"

const MIN_POP_RESERVED = 10000

#征兵
func _init() -> void:
	LoadControl.view_model_name = "内政-玩家-步骤";
	FlowManager.bind_signal_method("conscription_start", self)
	FlowManager.bind_signal_method("conscription_2", self)
	FlowManager.bind_signal_method("conscription_3", self)
	FlowManager.bind_signal_method("conscription_4", self)
	FlowManager.bind_signal_method("conscription_5", self)
	FlowManager.bind_signal_method("conscription_6", self)
	FlowManager.bind_signal_method("conscription_6_1", self)
	FlowManager.bind_signal_method("conscription_7", self)
	FlowManager.bind_signal_method("zero_soldiers", self)
	return

#按键操控
func _input_key(delta: float):
	var scene_affiars:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	match view_model:
		221: #确认对话
			wait_for_confirmation("conscription_2", "enter_barrack_menu")
		222: #输入数字
			if not wait_for_number_input("enter_barrack_menu", true):
				return
			#确认数量
			var conNumberInput = SceneManager.input_numbers.get_current_input_node();
			var number:int = conNumberInput.get_number();
			DataManager.set_env("数量", number)
			if number > 0:
				FlowManager.add_flow("conscription_3");
			else:
				FlowManager.add_flow("conscription_7");
		223: #征兵流程：命令书
			wait_for_yesno("conscription_4", "enter_barrack_menu")
		226:
			wait_for_confirmation("conscription_7")
		227: #征兵流程：分配兵力给武将
			if Input.is_action_just_pressed("ANALOG_LEFT"):
				SceneManager.actorlist.decrease_sodiers()
				return
			if Input.is_action_just_pressed("ANALOG_RIGHT"):
				SceneManager.actorlist.increase_sodiers()
				return
			if not wait_for_choose_actor("zero_soldiers", false, true):
				return
			if Input.is_action_just_pressed("EMU_START"):
				SceneManager.actorlist.move_to(-1)
				return
			var aindex = SceneManager.actorlist.get_select_actor()
			if aindex == -1:
				Input.action_release("EMU_X")
				FlowManager.add_flow("city_enter_menu");
			else:
				Input.action_release("EMU_A")
				if Global.is_action_pressed_AX():
					SceneManager.actorlist.full_all_sodiers()
				else:
					SceneManager.actorlist.increase_to_full_sodiers()
	return

func zero_soldiers():
	if Global.is_action_pressed_BY():
		SceneManager.actorlist.clear_all_sodiers()
	else:
		SceneManager.actorlist.decrease_to_zero_sodiers()

#征兵开始（221）:
func conscription_start():
	var city = clCity.city(DataManager.player_choose_city)
	var msg = "人口{1}以上才可征兵\n每100士兵需{0}两金".format([
		city.get_soldier_price(), MIN_POP_RESERVED
	])
	SceneManager.show_confirm_dialog(msg)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(221)
	return

#输入征兵数量
func conscription_2():
	var city = clCity.city(DataManager.player_choose_city)
	var can_money_con = int(city.get_gold() / city.get_soldier_price() * 100)
	#金可征兵数
	if can_money_con < 100:
		var msg = "当前金\n不足以招募100兵"
		DataManager.set_env("对话", msg)
		FlowManager.add_flow("conscription_6_1");
		return
	#可征人口数
	var can_use_peo = city.get_pop() - MIN_POP_RESERVED
	if can_use_peo < 100:
		var msg = "人口至少{0}才可征兵\n当前人口不足".format([MIN_POP_RESERVED])
		DataManager.set_env("对话", msg)
		FlowManager.add_flow("conscription_6_1")
		return
	var max_sodiers = max(0, min(can_money_con, can_use_peo))
	
	SceneManager.show_input_numbers("请输入征兵数目", ["士兵"], [max_sodiers], [2])
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(222)
	return

#命令书
func conscription_3():
	SceneManager.show_yn_dialog("消耗1枚命令书可否")
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(223)
	return

#防灾：命令书消耗动画
func conscription_4():
	SceneManager.dialog_use_orderbook_animation("conscription_5")
	LoadControl.set_view_model(224)
	return

#动画
func conscription_5():
	var city = clCity.city(DataManager.player_choose_city)
	var number = DataManager.get_env_int("数量")
	var cost = int(number * city.get_soldier_price() / 100)
	city.add_city_property("后备兵", number)
	city.add_city_property("人口", -number)
	city.add_gold(-cost)
	SceneManager.show_unconfirm_dialog("")
	SceneManager.play_affiars_animation("Barrack_Conscription","conscription_6");
	LoadControl.set_view_model(225)
	return

#确认
func conscription_6():
	LoadControl.set_view_model(226);
	SceneManager.show_confirm_dialog(" ");
	SceneManager.show_cityInfo(true);

#进入武将列表
func conscription_7():
	LoadControl.set_view_model(227);
	var scene_affiars:Control = SceneManager.current_scene();
	scene_affiars.cursor.hide();
	var city = clCity.city(DataManager.player_choose_city)
	SceneManager.show_actorlist_army(city.get_actor_ids(), true, "调整谁的兵力?", true);
	return

func conscription_6_1():
	LoadControl.set_view_model(226);
	SceneManager.show_confirm_dialog(DataManager.common_variable["对话"]);
	SceneManager.show_cityInfo(true);
