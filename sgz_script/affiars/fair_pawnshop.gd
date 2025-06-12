extends "affairs_base.gd"

#医馆
func _init() -> void:
	LoadControl.view_model_name = "内政-玩家-步骤";
	FlowManager.bind_signal_method("pawnshop_menu",self,"pawnshop_menu");
	#米
	FlowManager.bind_signal_method("pawnshop_rice_menu",self,"pawnshop_rice_menu");
	FlowManager.bind_signal_method("pawnshop_rice_buy_start",self,"pawnshop_rice_buy_start");
	FlowManager.bind_signal_method("pawnshop_rice_buy_use_orderbook_start",self,"pawnshop_rice_buy_use_orderbook_start");
	FlowManager.bind_signal_method("pawnshop_rice_buy_use_orderbook_end",self,"pawnshop_rice_buy_use_orderbook_end");
	FlowManager.bind_signal_method("pawnshop_rice_buy_animation",self,"pawnshop_rice_buy_animation");
	
	FlowManager.bind_signal_method("pawnshop_rice_sell_start",self,"pawnshop_rice_sell_start");
	FlowManager.bind_signal_method("pawnshop_rice_sell_use_orderbook_start",self,"pawnshop_rice_sell_use_orderbook_start");
	FlowManager.bind_signal_method("pawnshop_rice_sell_use_orderbook_end",self,"pawnshop_rice_sell_use_orderbook_end");
	FlowManager.bind_signal_method("pawnshop_rice_sell_animation",self,"pawnshop_rice_sell_animation");

	#宝物
	FlowManager.bind_signal_method("pawnshop_treasure_sell_start",self,"pawnshop_treasure_sell_start");
	FlowManager.bind_signal_method("pawnshop_treasure_sell_use_orderbook_start",self,"pawnshop_treasure_sell_use_orderbook_start");
	FlowManager.bind_signal_method("pawnshop_treasure_sell_use_orderbook_end",self,"pawnshop_treasure_sell_use_orderbook_end");
	FlowManager.bind_signal_method("pawnshop_treasure_sell_animation",self,"pawnshop_treasure_sell_animation");
	
	return

#按键操控
func _input_key(delta: float):
	var scene_affiars:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	match view_model:
		440:#主菜单（米、宝物）
			wait_for_options(["pawnshop_rice_menu", "pawnshop_treasure_sell_start"], "enter_fair_menu")
		441:#输入卖宝数量
			if not wait_for_number_input("pawnshop_menu"):
				return
			var conNumberInput = SceneManager.input_numbers.get_current_input_node();
			var number:int = conNumberInput.get_number();
			#确认数量
			DataManager.common_variable["数量"]=number;
			FlowManager.add_flow("pawnshop_treasure_sell_use_orderbook_start");
		442:#命令书
			wait_for_yesno("pawnshop_treasure_sell_use_orderbook_end", "enter_fair_menu")
		450:#米屋 菜单
			wait_for_options(["pawnshop_rice_buy_start", "pawnshop_rice_sell_start"], "pawnshop_menu")
		451:#输入买米数量
			wait_for_number_input("pawnshop_rice_menu")
			var conNumberInput = SceneManager.input_numbers.get_current_input_node();
			var number:int = conNumberInput.get_number();
			var price = DataManager.get_city_rice_price(DataManager.player_choose_city)
			var money = int(number/(price/100.0));
			SceneManager.input_numbers.speak2("（金 {0}）".format([money]));
			if Global.is_action_pressed_AX():
				if number==0:
					return
				#确认数量
				DataManager.common_variable["数量"]=number;
				FlowManager.add_flow("pawnshop_rice_buy_use_orderbook_start");
		452:#命令书
			wait_for_yesno("pawnshop_rice_buy_use_orderbook_end", "enter_fair_menu")
		461:#输入卖米数量
			wait_for_number_input("pawnshop_rice_menu")
			var conNumberInput = SceneManager.input_numbers.get_current_input_node();
			var number:int = conNumberInput.get_number();
			var price = DataManager.get_city_rice_price(DataManager.player_choose_city, true)
			var money = int(number*price/100);
			SceneManager.input_numbers.speak2("（金 {0}）".format([money]));
			if Global.is_action_pressed_AX():
				if number==0:
					return
				#确认数量
				DataManager.common_variable["数量"]=number;
				FlowManager.add_flow("pawnshop_rice_sell_use_orderbook_start");
		462:#命令书
			wait_for_yesno("pawnshop_rice_sell_use_orderbook_end", "enter_fair_menu")
	return

func pawnshop_menu():
	LoadControl.set_view_model(440);
	var scene_affiars:Control = SceneManager.current_scene();
	scene_affiars.cursor.hide();
	DataManager.twinkle_citys = [DataManager.player_choose_city];
	SceneManager.hide_all_tool();
	var menu_array = ["米","宝物"];
	DataManager.common_variable["列表值"]=menu_array;
	SceneManager.lsc_menu.lsc.columns = 2;
	SceneManager.lsc_menu.lsc.items = menu_array;
	SceneManager.lsc_menu.set_lsc(Vector2(0, 50))
	SceneManager.lsc_menu.lsc._set_data();
	SceneManager.lsc_menu.show_msg("此处是店铺，交易何物？");
	SceneManager.lsc_menu.show_orderbook(true);
	SceneManager.show_cityInfo(true);
	SceneManager.lsc_menu.show();
	return

#------------米屋-------------
func pawnshop_rice_menu():
	LoadControl.set_view_model(450);
	var scene_affiars:Control = SceneManager.current_scene();
	scene_affiars.cursor.hide();
	DataManager.twinkle_citys = [DataManager.player_choose_city];
	SceneManager.hide_all_tool();
	var menu_array = ["买","卖"];
	DataManager.common_variable["列表值"]=menu_array;
	SceneManager.lsc_menu.lsc.columns = 2;
	SceneManager.lsc_menu.lsc.items = menu_array;
	SceneManager.lsc_menu.set_lsc(Vector2(0, 50));
	SceneManager.lsc_menu.lsc._set_data();
	SceneManager.lsc_menu.show_msg("买米还是卖米？");
	SceneManager.lsc_menu.show_orderbook(true);
	SceneManager.show_cityInfo(true);
	SceneManager.lsc_menu.show();

#--买米--
#输入买米量
func pawnshop_rice_buy_start():
	LoadControl.set_view_model(451);
	var city = clCity.city(DataManager.player_choose_city)
	var price = DataManager.get_city_rice_price(city.ID)
	var max_rice = int(price * city.get_gold() / 100.0);
	max_rice = min(max_rice, 9999 - city.get_rice())
	
	SceneManager.show_input_numbers("每100两金可买得"+str(price)+"石米",["米"],[max_rice],[0]);
	SceneManager.show_cityInfo(true);
	SceneManager.input_numbers.show_orderbook(true);
	return

#命令书
func pawnshop_rice_buy_use_orderbook_start():
	LoadControl.set_view_model(452);
	#命令书确认
	SceneManager.show_yn_dialog("消耗1枚命令书可否");
	SceneManager.show_cityInfo(true);

#命令书消耗动画
func pawnshop_rice_buy_use_orderbook_end():
	LoadControl.set_view_model(453);
	SceneManager.dialog_use_orderbook_animation("pawnshop_rice_buy_animation");

#动画
func pawnshop_rice_buy_animation():
	LoadControl.set_view_model(454);
	#买米数量
	var number = int(DataManager.common_variable["数量"]);
	var city = clCity.city(DataManager.player_choose_city)
	var price = DataManager.get_city_rice_price(city.ID)
	var money = int(number/(price/100.0));
	city.add_rice(number)
	city.add_gold(-money)
	
	DataManager.common_variable["对话"]="收入{0}石米".format([number]);
	SceneManager.show_unconfirm_dialog(DataManager.common_variable["对话"]);
	SceneManager.play_affiars_animation("Fair_HockShop","confirm_to_ready");

#--卖米
#输入卖米量
func pawnshop_rice_sell_start():
	LoadControl.set_view_model(461);
	var city = clCity.city(DataManager.player_choose_city)
	var price = DataManager.get_city_rice_price(city.ID, true)
	var max_rice = min(city.get_rice(), ceil(float(9999 - city.get_gold()) * 100.0 / float(price)))
	SceneManager.show_input_numbers("每100石米可卖得"+str(price)+"两金",["米"],[max_rice],[0]);
	SceneManager.show_cityInfo(true);
	
#命令书
func pawnshop_rice_sell_use_orderbook_start():
	LoadControl.set_view_model(462);
	#命令书确认
	SceneManager.show_yn_dialog("消耗1枚命令书可否");
	SceneManager.show_cityInfo(true);

#命令书消耗动画
func pawnshop_rice_sell_use_orderbook_end():
	LoadControl.set_view_model(463);
	SceneManager.dialog_use_orderbook_animation("pawnshop_rice_sell_animation");

#动画
func pawnshop_rice_sell_animation():
	LoadControl.set_view_model(464);
	#卖米数量
	var number = int(DataManager.common_variable["数量"]);
	var city = clCity.city(DataManager.player_choose_city)
	var price = DataManager.get_city_rice_price(city.ID, true)
	var money = int(number*price/100);
	city.add_rice(-number)
	city.add_gold(money)
	
	DataManager.common_variable["对话"]="收入{0}两金".format([money]);
	SceneManager.show_unconfirm_dialog(DataManager.common_variable["对话"]);
	SceneManager.play_affiars_animation("Fair_HockShop","confirm_to_ready");


#------------宝物-------------
func pawnshop_treasure_sell_start():
	var city = clCity.city(DataManager.player_choose_city)
	var treasures = city.get_treasures()
	if treasures <= 0:
		LoadControl._affiars_error("现如今城内并无宝物\n请下达其他命令");
		return;
	treasures = min(treasures, (9999 - city.get_gold()) / 100)
	if treasures <= 0:
		LoadControl._affiars_error("城市资金充足\n请下达其他命令");
		return;

	LoadControl.set_view_model(441);
	SceneManager.show_input_numbers("每件宝物值100两金",["宝"],[treasures],[0]);
	SceneManager.show_cityInfo(true);

#命令书
func pawnshop_treasure_sell_use_orderbook_start():
	LoadControl.set_view_model(442);
	#命令书确认
	SceneManager.show_yn_dialog("消耗1枚命令书可否");
	SceneManager.show_cityInfo(true);

#命令书消耗动画
func pawnshop_treasure_sell_use_orderbook_end():
	LoadControl.set_view_model(443);
	SceneManager.dialog_use_orderbook_animation("pawnshop_treasure_sell_animation");

#动画
func pawnshop_treasure_sell_animation():
	LoadControl.set_view_model(444);
	var number = int(DataManager.common_variable["数量"]);
	var city = clCity.city(DataManager.player_choose_city)
	var money = number * 100;
	city.add_city_property("宝", -number)
	city.add_city_property("金", money)
	
	DataManager.common_variable["对话"]="收入{0}两金".format([money]);
	SceneManager.show_unconfirm_dialog(DataManager.common_variable["对话"]);
	SceneManager.play_affiars_animation("Fair_HockShop","confirm_to_ready");
	return

