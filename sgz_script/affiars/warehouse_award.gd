extends "affairs_base.gd"


#赏赐
func _init() -> void:
	LoadControl.view_model_name = "内政-玩家-步骤"
	FlowManager.bind_signal_method("award_menu", self)
	FlowManager.bind_signal_method("award_actor_menu", self)
	#赏赐武将-金
	FlowManager.bind_signal_method("award_actor_money_start", self)
	FlowManager.bind_signal_method("award_actor_money_2", self)
	FlowManager.bind_signal_method("award_actor_money_3", self)
	FlowManager.bind_signal_method("award_actor_money_4", self)
	FlowManager.bind_signal_method("award_actor_money_5", self)
	FlowManager.bind_signal_method("award_actor_money_6", self)
	#赏赐武将-宝物
	FlowManager.bind_signal_method("award_actor_treasure_start", self)
	FlowManager.bind_signal_method("award_actor_treasure_2", self)
	FlowManager.bind_signal_method("award_actor_treasure_3", self)
	FlowManager.bind_signal_method("award_actor_treasure_4", self)
	FlowManager.bind_signal_method("award_actor_treasure_5", self)
	#赏赐民众
	FlowManager.bind_signal_method("award_people_start", self)
	FlowManager.bind_signal_method("award_people_2", self)
	FlowManager.bind_signal_method("award_people_3", self)
	FlowManager.bind_signal_method("award_people_4", self)
	FlowManager.bind_signal_method("award_people_5", self)
	
	FlowManager.clear_pre_history.append("award_menu");
	FlowManager.clear_pre_history.append("award_actor_menu");
	return

#按键操控
func _input_key(delta: float):
	var scene_affiars:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	match view_model:
		320:#赏赐菜单
			wait_for_options(["award_actor_menu", "award_people_start"], "enter_warehouse_menu")
		321:#给民众金米
			#输入金和米
			if not wait_for_number_input("award_menu", true):
				return
			var conNumberInput = SceneManager.input_numbers.get_current_input_node();
			var number:int = conNumberInput.get_number();
			#确认数量
			DataManager.common_variable["赏赐数量"][SceneManager.input_numbers.input_index]=number;
			if(SceneManager.input_numbers.next_input_index()):
				var input = SceneManager.input_numbers.get_current_input_node();
				input.set_number(0,true);
			else:
				var numbers = PoolIntArray(DataManager.common_variable["赏赐数量"])
				if numbers[0] + numbers[1] == 0:
					return
				#同步数据
				FlowManager.add_flow("award_people_2");
		322:#命令书
			wait_for_yesno("award_people_3", "enter_warehouse_menu")
		325:#确认对话
			wait_for_confirmation()
		330:#赏赐武将种类
			wait_for_options(["award_actor_money_start", "award_actor_treasure_start"], "award_menu")
		331:#输入金数量
			if not wait_for_number_input("award_menu"):
				return
			var conNumberInput = SceneManager.input_numbers.get_current_input_node();
			var number:int = conNumberInput.get_number();
			DataManager.common_variable["花费"]=number;
			FlowManager.add_flow("award_actor_money_2");
		332:#选择武将
			if not wait_for_choose_actor("award_menu"):
				return
			var actorId = SceneManager.actorlist.get_select_actor();
			var actor = ActorHelper.actor(actorId)
			if actor.get_loyalty() == 100:
				SceneManager.actorlist.speak("此乃君主")
				return
			if actor.get_loyalty() >= 90:
				LoadControl._affiars_error("臣无需此类无用之物", actorId)
				return
			DataManager.player_choose_actor = actorId
			FlowManager.add_flow("award_actor_money_3")
		333:#命令书
			wait_for_yesno("award_actor_money_4", "enter_warehouse_menu")
		336:#确认对话
			wait_for_confirmation()
		341:#赏赐宝物：选择武将
			if not wait_for_choose_actor("award_menu"):
				return
			var actorId = SceneManager.actorlist.get_select_actor();
			var actor = ActorHelper.actor(actorId)
			if actor.get_loyalty() == 100:
				SceneManager.actorlist.speak("此乃君主")
				return
			DataManager.player_choose_actor = actorId
			FlowManager.add_flow("award_actor_treasure_2")
		342:#命令书
			wait_for_yesno("award_actor_treasure_3", "enter_warehouse_menu")
		345:#确认对话
			wait_for_confirmation()
	return


#数字意义：
# 320:赏赐主菜单
# 321开始:赏赐民众流程
# 330:赏赐武将菜单
# 331开始:赏赐武将金流程
# 341开始:赏赐武将宝物流程


#赏赐主菜单(320)：选择武将或民众
func award_menu():
	LoadControl.set_view_model(320);
	var scene_affiars:Control = SceneManager.current_scene();
	scene_affiars.cursor.hide();
	DataManager.twinkle_citys = [DataManager.player_choose_city];
	SceneManager.hide_all_tool();
	var menu_array = ["麾下武将","城内民众"];
	
	DataManager.common_variable["列表值"]=menu_array;
	SceneManager.lsc_menu.lsc.columns = 1;
	SceneManager.lsc_menu.lsc.items = menu_array;
	SceneManager.lsc_menu.set_lsc()
	SceneManager.lsc_menu.lsc._set_data();
	SceneManager.lsc_menu.show_msg("赏赐何人？");
	SceneManager.lsc_menu.show_orderbook(true);
	SceneManager.show_cityInfo(true);
	SceneManager.lsc_menu.show();

#--------------赏赐民众--------------
#赏赐民众开始(321):输入金米数量
func award_people_start():
	LoadControl.set_view_model(321);
	SceneManager.hide_all_tool();
	var city = clCity.city(DataManager.player_choose_city)
	if city.get_loyalty() >= 100:
		LoadControl._error("民众均已心悦诚服", city.get_leader_id(), 1)
		return
	var props = ["金", "米"]
	var limits = [
		min(city.get_gold(), 100),
		min(city.get_rice(), 100)
	]
	var digits = [1, 1]
	DataManager.common_variable["赏赐数量"] = [0, 0]
	SceneManager.show_input_numbers("下发多少金米?", props, limits, digits)
	SceneManager.show_cityInfo(true)
	return

#消耗命令书
func award_people_2():
	LoadControl.set_view_model(322);
	#命令书确认
	SceneManager.show_yn_dialog("消耗1枚命令书可否");
	SceneManager.show_cityInfo(true);

func award_people_3():
	LoadControl.set_view_model(323);
	SceneManager.dialog_use_orderbook_animation("award_people_4");

#动画
func award_people_4():
	LoadControl.set_view_model(324);
	var city = clCity.city(DataManager.player_choose_city)
	var numbers = DataManager.get_env_int_array("赏赐数量")
	var vstateId = city.get_vstate_id()
	var money = numbers[0]
	var rice = numbers[1]
	var satrap = ActorHelper.actor(city.get_actor_ids()[0])
	var added = satrap.get_moral() * (money + rice) / 2000 * Global.get_random(10, 16) / 10
	var timesBuff = SkillRangeBuff.max_for_city("赏赐民众倍率", city.ID)
	if timesBuff != null:
		added = int(added * timesBuff.effectTagVal)
	added = city.add_loyalty(added)
	city.add_gold(-money)
	city.add_rice(-rice)
	var msg = "民众非常高兴\n统治度上升{0}点".format([added])
	var extra = SkillRangeBuff.max_val_for_city("赏赐民众效果", city.ID)
	if extra > 0:
		extra = city.add_loyalty(extra)
	if extra > 0:
		msg = "民众非常高兴\n统治度上升{0}+{1}点".format([added, extra])
	if timesBuff != null:
		msg += "\n（{0}【{1}】{2}倍效果".format([
			ActorHelper.actor(timesBuff.actorId).get_name(),
			timesBuff.skillName, int(timesBuff.effectTagVal),
		])
	DataManager.set_env("对话", msg)
	SceneManager.show_unconfirm_dialog("");
	OrderHistory.record_order(city.get_vstate_id(), "赏赐民众", satrap.actorId)
	SceneManager.play_affiars_animation("Warehouse_AwardPop","award_people_5");
	return

#确认对话
func award_people_5():
	var city = clCity.city(DataManager.player_choose_city)
	var msg = DataManager.get_env_str("对话")
	SceneManager.show_confirm_dialog(msg, city.get_leader_id(), 1)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(325)
	return

#--------------赏赐武将--------------
#赏赐武将菜单（330）：选择赏赐种类（金或者宝）
func award_actor_menu():
	LoadControl.set_view_model(330);
	DataManager.twinkle_citys = [DataManager.player_choose_city];
	var city = clCity.city(DataManager.player_choose_city)
	var actors = []
	for actorId in city.get_actor_ids():
		if ActorHelper.actor(actorId).get_loyalty() >= 99:
			continue
		actors.append(actorId)
	if actors.empty():
		LoadControl._error("众将均已忠心不二", city.get_leader_id(), 1)
		return
	SceneManager.current_scene().cursor.hide()
	SceneManager.hide_all_tool()
	var menu_array = ["金","宝物"];
	DataManager.common_variable["列表值"] = menu_array;
	SceneManager.lsc_menu.lsc.columns = 2;
	SceneManager.lsc_menu.lsc.items = menu_array;
	SceneManager.lsc_menu.set_lsc(Vector2(0, 50))
	SceneManager.lsc_menu.lsc._set_data();
	SceneManager.lsc_menu.show_msg("赏赐何物？");
	SceneManager.lsc_menu.show_orderbook(true);
	SceneManager.show_cityInfo(true);
	SceneManager.lsc_menu.show();
	return

#----赏赐武将（金）----
#赏赐武将金（331）：输入金数量
func award_actor_money_start():
	LoadControl.set_view_model(331);
	SceneManager.hide_all_tool();
	var city = clCity.city(DataManager.player_choose_city)
	var max_money = min(city.get_gold(), 100)
	SceneManager.show_input_numbers("赏赐多少两金?",["金"],[max_money],[1]);
	SceneManager.show_cityInfo(true);

#赏赐武将金：选择武将
func award_actor_money_2():
	LoadControl.set_view_model(332);
	var city = clCity.city(DataManager.player_choose_city)
	var actors = []
	for actorId in city.get_actor_ids():
		if ActorHelper.actor(actorId).get_loyalty() >= 90:
			continue
		actors.append(actorId)
	if actors.empty():
		LoadControl._error("财帛难动义士之心")
		return
	SceneManager.current_scene().cursor.hide();
	DataManager.twinkle_citys = [city.ID];
	SceneManager.show_actorlist_army(actors,false,"赏赐何人？请指定",false);
	return

#消耗命令书
func award_actor_money_3():
	LoadControl.set_view_model(333);
	#命令书确认
	SceneManager.show_yn_dialog("消耗1枚命令书可否");
	SceneManager.show_cityInfo(true);

#防灾：命令书消耗动画
func award_actor_money_4():
	LoadControl.set_view_model(334);
	SceneManager.dialog_use_orderbook_animation("award_actor_money_5");

#动画
func award_actor_money_5():
	LoadControl.set_view_model(-1)
	var gold = DataManager.get_env_int("花费")
	var actor = ActorHelper.actor(DataManager.player_choose_actor)
	var current = actor.get_loyalty()
	var city = clCity.city(DataManager.player_choose_city)
	var vstateId = city.get_vstate_id()
	var lord = ActorHelper.actor(city.get_lord_id())
	var val = add_actor_loyalty(lord, actor, gold)
	city.add_gold(-gold)
	var msg = "谢{0}厚情\n（忠诚度上升{1}，现为{2}"
	var extra = SkillRangeBuff.max_val_for_city("赏赐武将效果", city.ID)
	if extra > 0:
		extra = actor.add_loyalty(extra)
		if extra > 0:
			msg = "谢{0}厚情\n忠诚度上升{1} (+{3})\n现为{2}"
	else:
		extra = 0
	if actor.get_moral() < 50 and current < 70:
		var extra2 = SkillRangeBuff.max_val_for_city("赏金低德武将效果", city.ID)
		if extra2 > 0:
			extra2 = actor.add_loyalty(extra2)
			if extra2 > 0:
				extra += extra2
				msg = "却之不恭，多多益善\n忠诚度上升{1} (+{3})\n现为{2}"
	msg = msg.format([
		DataManager.get_actor_honored_title(lord.actorId, actor.actorId),
		val, actor.get_loyalty(), extra
	])
	DataManager.set_env("对话", msg)
	SceneManager.show_unconfirm_dialog("")
	DataManager.set_env("赏赐物", "金|{0}".format([gold]))
	OrderHistory.record_order(city.get_vstate_id(), "赏赐武将", actor.actorId)
	DataManager.set_env("内政.命令", "赏赐武将")
	if SkillHelper.auto_trigger_skill(actor.actorId, 10012, "award_actor_money_6"):
		return
	DataManager.unset_env("赏赐物")
	FlowManager.add_flow("award_actor_money_6")
	return

#确认对话
func award_actor_money_6():
	var msg = DataManager.get_env_str("对话")
	SceneManager.play_affiars_animation("Warehouse_AwardActor", "", false, msg, DataManager.player_choose_actor, 1)
	LoadControl.set_view_model(336)
	return

#----赏赐武将（宝）----
#赏赐武将宝（341）：选择武将
func award_actor_treasure_start():
	var city = clCity.city(DataManager.player_choose_city)
	if city.get_treasures() <= 0:
		LoadControl._affiars_error("现如今此城内并无宝物\n请下达其他命令");
		return;
	LoadControl.set_view_model(341);
	SceneManager.current_scene().cursor.hide();
	DataManager.twinkle_citys = [city.ID];
	var actors = []
	for actorId in city.get_actor_ids():
		if ActorHelper.actor(actorId).get_loyalty() >= 99:
			continue
		actors.append(actorId)
	if actors.empty():
		LoadControl._error("众将均已忠心不二")
		return
	SceneManager.show_actorlist_develop(actors,false,"赏赐何人？请指定");

#消耗命令书
func award_actor_treasure_2():
	LoadControl.set_view_model(342);
	#命令书确认
	SceneManager.show_yn_dialog("消耗1枚命令书可否");
	SceneManager.show_cityInfo(true);

#命令书消耗动画
func award_actor_treasure_3():
	LoadControl.set_view_model(343);
	SceneManager.dialog_use_orderbook_animation("award_actor_treasure_4");

#动画
func award_actor_treasure_4():
	LoadControl.set_view_model(-1)
	var actor = ActorHelper.actor(DataManager.player_choose_actor)
	var current = actor.get_loyalty()
	var city = clCity.city(DataManager.player_choose_city)
	var vstateId = city.get_vstate_id()
	var lord = ActorHelper.actor(city.get_lord_id())
	var val = add_actor_loyalty(lord, actor, 0, 1)
	city.add_city_property("宝", -1)
	var msg = "谢{0}殊遇\n（忠诚度上升{1}点，现为{2}"
	var extra = SkillRangeBuff.max_val_for_city("赏赐武将效果", city.ID)
	if extra > 0:
		extra = actor.add_loyalty(extra)
		if extra > 0:
			msg = "谢{0}殊遇\n忠诚度上升{1} (+{3})\n现为{2}"
	else:
		extra = 0
	if actor.get_moral() < 50 and current < 70:
		var extra2 = SkillRangeBuff.max_val_for_city("赏宝低德武将效果", city.ID)
		if extra2 > 0:
			extra2 = actor.add_loyalty(extra2)
			if extra2 > 0:
				extra += extra2
				msg = "却之不恭，多多益善\n忠诚度上升{1} (+{3})\n现为{2}"
	msg = msg.format([
		DataManager.get_actor_honored_title(lord.actorId, actor.actorId),
		val, actor.get_loyalty(), extra
	])
	DataManager.set_env("对话", msg)
	SceneManager.show_unconfirm_dialog("")
	DataManager.set_env("赏赐物", "宝|1")
	OrderHistory.record_order(city.get_vstate_id(), "赏赐武将", actor.actorId)
	DataManager.set_env("内政.命令", "赏赐武将")
	if SkillHelper.auto_trigger_skill(actor.actorId, 10012, "award_actor_treasure_5"):
		return
	DataManager.unset_env("赏赐物")
	SceneManager.play_affiars_animation("Warehouse_AwardActor", "award_actor_treasure_5")
	return

#确认对话
func award_actor_treasure_5():
	var msg = DataManager.get_env_str("对话")
	SceneManager.play_affiars_animation("Warehouse_AwardActor", "", false, msg, DataManager.player_choose_actor, 1)
	LoadControl.set_view_model(345)
	return
