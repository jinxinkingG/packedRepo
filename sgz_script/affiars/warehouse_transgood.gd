extends "affairs_base.gd"



#物资运输
func _init() -> void:
	LoadControl.view_model_name = "内政-玩家-步骤";
	FlowManager.bind_signal_method("transgoods_start",self,"transgoods_start");
	FlowManager.bind_signal_method("transgoods_2",self,"transgoods_2");
	FlowManager.bind_signal_method("transgoods_3",self,"transgoods_3");
	FlowManager.bind_signal_method("transgoods_4",self,"transgoods_4");
	FlowManager.bind_signal_method("transgoods_5",self,"transgoods_5");
	return

#按键操控
func _input_key(delta: float):
	var scene_affiars:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	match view_model:
		311: #运输流程：选择城市
			var fromCity = clCity.city(DataManager.player_choose_city)
			var targetCityIds = fromCity.get_transfer_city_ids(true)
			var cityId = wait_for_choose_city(delta, "enter_warehouse_menu", targetCityIds)
			if cityId < 0:
				return
			if cityId == fromCity.ID:
				SceneManager.show_unconfirm_dialog("本城何须劳力运输？")
				return
			# 判断相连和归属
			if not cityId in targetCityIds:
				SceneManager.show_unconfirm_dialog("无法运送至该城")
				return
			DataManager.set_env("目标城", cityId)
			FlowManager.add_flow("transgoods_2")
		312: #输入数字
			if not wait_for_number_input("enter_warehouse_menu", true):
				return
			var conNumberInput = SceneManager.input_numbers.get_current_input_node();
			var number:int = conNumberInput.get_number();
			#确认数量
			DataManager.common_variable["运送数量"][SceneManager.input_numbers.input_index]=number;
			if(SceneManager.input_numbers.next_input_index()):
				var input = SceneManager.input_numbers.get_current_input_node();
				input.set_number(0,true);
			else:
				#同步数据
				var total = 0
				for i in DataManager.common_variable["运送数量"].size():
					total += DataManager.common_variable["运送数量"][i]
				if total > 0:
					LoadControl.set_view_model(-1)
					FlowManager.add_flow("transgoods_3");
				else:
					return
		313: #命令书
			wait_for_yesno("transgoods_4", "enter_warehouse_menu")
		314: #无须运输
			wait_for_confirmation("enter_warehouse_menu")
	return

#物资运输开始（311）：选择目标城池
func transgoods_start():
	SceneManager.clear_bottom();
	DataManager.twinkle_citys.clear();
	var scene_affiars:Control = SceneManager.current_scene();
	var vstate_controlNo = DataManager.get_current_control_sort()
	var player:Player = DataManager.players[vstate_controlNo];
	scene_affiars.cursor.show();
	scene_affiars.set_city_cursor_position(DataManager.player_choose_city);
	SceneManager.show_unconfirm_dialog("向哪座城池运送物资？\n请指定");
	LoadControl.set_view_model(311)

#输入运送数量
func transgoods_2():
	var targetCityId = int(DataManager.common_variable["目标城"])
	var targetCity = clCity.city(targetCityId)
	var fromCity = clCity.city(DataManager.player_choose_city)
	DataManager.twinkle_citys = [fromCity.ID, targetCity.ID]
	var inputNames = ["金","米","宝","兵"]
	var transProps = ["金","米","宝","后备兵"]
	var transLimits = []
	var allZero = true
	for prop in transProps:
		var limit = clCity.CITY_PROPERTY_MAX[prop] - int(targetCity.get_property(prop))
		limit = min(limit, int(fromCity.get_property(prop)))
		limit = max(0, limit)
		transLimits.append(limit)
		if limit > 0:
			allZero = false
	if allZero:
		SceneManager.show_confirm_dialog("{0}资源充足\n无须补充任何物资".format([
			targetCity.get_name()
		]))
		LoadControl.set_view_model(314)
		return
	DataManager.common_variable["运送数量"] = [0,0,0,0]
	SceneManager.show_input_numbers("请选择运送数量", inputNames, transLimits)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(312)
	return

#消耗命令书
func transgoods_3():
	LoadControl.set_view_model(313);
	#命令书确认
	SceneManager.show_yn_dialog("消耗1枚命令书可否");
	SceneManager.show_cityInfo(true);

#防灾：命令书消耗动画
func transgoods_4():
	LoadControl.set_view_model(-1);
	SceneManager.dialog_use_orderbook_animation("transgoods_5");

#动画
func transgoods_5():
	LoadControl.set_view_model(315);
	var numbers = PoolIntArray(DataManager.common_variable["运送数量"]);
	var targetCityId = int(DataManager.common_variable["目标城"])
	var targetCity = clCity.city(targetCityId)
	var fromCity = clCity.city(DataManager.player_choose_city)

	fromCity.add_gold(-numbers[0])
	fromCity.add_rice(-numbers[1])
	fromCity.add_city_property("宝", -numbers[2])
	fromCity.add_city_property("后备兵", -numbers[3])

	targetCity.add_gold(numbers[0])
	targetCity.add_rice(numbers[1])
	targetCity.add_city_property("宝", numbers[2])
	targetCity.add_city_property("后备兵", numbers[3])

	DataManager.common_variable["对话"]="遵命，马上就去";
	SceneManager.show_unconfirm_dialog(DataManager.common_variable["对话"]);
	SceneManager.play_affiars_animation("Warehouse_Transgoods","confirm_to_ready");
	return
