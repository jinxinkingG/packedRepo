extends "affairs_base.gd"

#每页多少个势力
const pageSize = 12

#策略
func _init() -> void:
	LoadControl.view_model_name = "内政-玩家-步骤";

	FlowManager.bind_import_flow("enter_town_policy_menu",self,"enter_town_policy_menu");

	FlowManager.bind_signal_method("alliance_menu",self,"alliance_menu");
	FlowManager.bind_signal_method("alliance_2",self,"alliance_2");
	FlowManager.bind_signal_method("alliance_join_3",self,"alliance_join_3");
	FlowManager.bind_signal_method("alliance_join_4",self,"alliance_join_4");
	FlowManager.bind_signal_method("alliance_join_5",self,"alliance_join_5");
	FlowManager.bind_signal_method("alliance_join_6",self,"alliance_join_6");
	FlowManager.bind_signal_method("alliance_join_7",self,"alliance_join_7");
	FlowManager.bind_signal_method("alliance_join_success_1",self,"alliance_join_success_1");
	FlowManager.bind_signal_method("alliance_join_success_2",self,"alliance_join_success_2");

	FlowManager.bind_signal_method("alliance_break_3",self,"alliance_break_3");
	FlowManager.bind_signal_method("alliance_break_4",self,"alliance_break_4");
	FlowManager.bind_signal_method("alliance_break_5",self,"alliance_break_5");
	FlowManager.bind_signal_method("alliance_break_6",self,"alliance_break_6");

	FlowManager.bind_signal_method("wedge_start", self)
	FlowManager.bind_signal_method("wedge_2", self)
	FlowManager.bind_signal_method("wedge_3", self)
	FlowManager.bind_signal_method("wedge_4", self)
	FlowManager.bind_signal_method("wedge_5", self)
	FlowManager.bind_signal_method("wedge_6", self)
	FlowManager.bind_signal_method("wedge_7", self)

	FlowManager.bind_signal_method("canvass_start", self)
	FlowManager.bind_signal_method("canvass_2", self)
	FlowManager.bind_signal_method("canvass_3", self)
	FlowManager.bind_signal_method("canvass_4", self)
	FlowManager.bind_signal_method("canvass_5", self)
	FlowManager.bind_signal_method("canvass_6", self)
	FlowManager.bind_signal_method("canvass_7", self)
	
	FlowManager.bind_signal_method("incite_start", self)
	FlowManager.bind_signal_method("incite_2", self)
	FlowManager.bind_signal_method("incite_3", self)
	FlowManager.bind_signal_method("incite_4", self)
	FlowManager.bind_signal_method("incite_5", self)
	FlowManager.bind_signal_method("incite_6", self)
	FlowManager.bind_signal_method("incite_7", self)

	FlowManager.clear_pre_history.append("wedge_2")
	FlowManager.clear_pre_history.append("wedge_3")
	FlowManager.clear_pre_history.append("wedge_4")

	FlowManager.clear_pre_history.append("incite_2")
	FlowManager.clear_pre_history.append("incite_3")
	FlowManager.clear_pre_history.append("incite_4")

	FlowManager.clear_pre_history.append("canvass_2")
	FlowManager.clear_pre_history.append("canvass_3")
	FlowManager.clear_pre_history.append("canvass_4")

	return

#按键操控
func _input_key(delta: float):
	var scene_affiars:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var top = SceneManager.lsc_menu_top;
	var view_model = LoadControl.get_view_model();
	match view_model:
		150:
			if not wait_for_options([
				"alliance_menu", "wedge_start", "canvass_start","incite_start"
			], "enter_town_menu"):
				return
		111: #同盟列表
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
				FlowManager.add_flow("enter_town_policy_menu");
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				var index = top.lsc.cursor_index;
				var item_value_array = DataManager.common_variable["列表值"];
				var choose_vstateId = int(item_value_array[index]);
				if int(choose_vstateId)==-1:
					var page = DataManager.get_env_int("列表页码")
					var text = str(top.lsc.items[index])
					match text:
						"上一页":
							page -= 1
						"下一页":
							page += 1
					DataManager.set_env("列表页码", page)
					FlowManager.add_flow("alliance_menu")
					return;
				DataManager.common_variable["目标势力"] = choose_vstateId;
				FlowManager.add_flow("alliance_2");
		113: #武将列表
			if not wait_for_choose_actor("enter_town_policy_menu"):
				return
			DataManager.player_choose_actor = SceneManager.actorlist.get_select_actor();
			if SkillHelper.auto_trigger_skill(DataManager.player_choose_actor, 10008, ""):
				return;
			FlowManager.add_flow("alliance_join_4");
		114: #命令书
			wait_for_yesno("alliance_join_5", "enter_town_menu")
		116: #提示成功率
			wait_for_confirmation("alliance_join_7")
		118: #提示金额
			wait_for_yesno("alliance_join_success_2", "city_enter_menu")
		119:
			wait_for_confirmation()
		121: #地图选势力
			var currentVstateId = int(DataManager.vstates_sort[DataManager.vstate_no])
			var targetCityIds = DataManager.get_env_int_array("同盟对象")
			var msg = "请选择同盟对象"
			DataManager.show_orderbook = false
			SceneManager.show_unconfirm_dialog(msg)
			SceneManager.dialog_msg_complete(true)
			var cityId = wait_for_choose_city(delta, "enter_town_policy_menu", targetCityIds)
			if cityId < 0:
				DataManager.twinkle_citys = []
				var currentCityId = SceneManager.current_scene().get_curosr_point_city()
				if currentCityId < 0:
					return
				var currentCity = clCity.city(currentCityId)
				var targetVstateId = currentCity.get_vstate_id()
				if targetVstateId in [-1, currentVstateId]:
					return
				var months = DataManager.get_alliance_months(currentVstateId, targetVstateId)
				var twinkleCityIds = []
				for city in clCity.all_cities([targetVstateId]):
					twinkleCityIds.append(city.ID)
				DataManager.twinkle_citys = twinkleCityIds
				msg = "当前与{0}势力\n有{1}个月盟约"
				if months <= 0:
					msg = "当前与{0}势力\n尚无盟约"
				msg = msg.format([
					clVState.vstate(targetVstateId).get_lord_name(), months,
				])
				DataManager.show_orderbook = false
				SceneManager.show_unconfirm_dialog(msg)
				SceneManager.dialog_msg_complete(true)
				return
			# 判断归属
			var targetCity = clCity.city(cityId)
			var targetVstateId = targetCity.get_vstate_id()
			if targetVstateId in [-1, currentVstateId]:
				return
			DataManager.set_env("目标势力", targetVstateId)
			FlowManager.add_flow("alliance_2")
		133: #撕毁盟约
			wait_for_yesno("alliance_break_4", "enter_town_policy_menu")
		134: #命令书
			wait_for_yesno("alliance_break_5", "enter_town_menu")
		136:
			wait_for_confirmation()
		151: #离间:选城
			var cityId = wait_for_choose_city(delta, "enter_town_policy_menu", clCity.all_city_ids())
			if cityId < 0:
				return
			var vstateId = DataManager.vstates_sort[DataManager.vstate_no];
			var city = clCity.city(cityId)
			if city.get_vstate_id() in [-1, vstateId]:
				SceneManager.show_unconfirm_dialog("无法离间该城")
				return
			DataManager.common_variable["目标城"] = cityId
			FlowManager.add_flow("wedge_2")
		152: #离间目标选择：武将列表
			if not wait_for_choose_actor("wedge_start"):
				return
			var targetId = SceneManager.actorlist.get_select_actor();
			var target = ActorHelper.actor(targetId)
			if target.get_loyalty() == 100:
				SceneManager.actorlist.speak("不可离间君主")
				return;
			DataManager.common_variable["目标武将"] = targetId
			FlowManager.add_flow("wedge_3")
		153: #武将列表
			if not wait_for_choose_actor("enter_town_policy_menu"):
				return
			DataManager.player_choose_actor = SceneManager.actorlist.get_select_actor();
			if SkillHelper.auto_trigger_skill(DataManager.player_choose_actor, 10008, ""):
				return
			FlowManager.add_flow("wedge_4")
		154: #命令书
			wait_for_yesno("wedge_5", "enter_town_menu")
		157:
			wait_for_confirmation("wedge_7")
		281: #挑唆:选城
			var cityId = wait_for_choose_city(delta, "enter_town_policy_menu", clCity.all_city_ids())
			if cityId < 0:
				return
			var vstateId = DataManager.vstates_sort[DataManager.vstate_no];
			var city = clCity.city(cityId)
			if city.get_vstate_id() in [-1, vstateId]:
				SceneManager.show_unconfirm_dialog("无法挑唆该城")
				return
			DataManager.common_variable["目标城"] = cityId
			FlowManager.add_flow("incite_2")
		282: #挑唆目标选择：武将列表
			if not wait_for_choose_actor("incite_start"):
				return
			var targetId = SceneManager.actorlist.get_select_actor();
			var target = ActorHelper.actor(targetId)
			if target.get_loyalty() == 100:
				SceneManager.actorlist.speak("不可挑唆君主")
				return;
			var targetCityId = int(DataManager.common_variable["目标城"]);
			var targetCity = clCity.city(targetCityId)
			if target.actorId != targetCity.get_actor_ids()[0]:
				SceneManager.actorlist.speak("只能挑唆太守")
				return;
			DataManager.common_variable["目标武将"] = target.actorId
			FlowManager.add_flow("incite_3")
		283: #武将列表
			if not wait_for_choose_actor("enter_town_policy_menu"):
				return
			DataManager.player_choose_actor = SceneManager.actorlist.get_select_actor();
			if SkillHelper.auto_trigger_skill(DataManager.player_choose_actor, 10008, ""):
				return
			FlowManager.add_flow("incite_4")
		284: #命令书
			wait_for_yesno("incite_5", "enter_town_menu")
		287:
			wait_for_confirmation("incite_7")
		161: #招揽:选城
			var cityId = wait_for_choose_city(delta, "enter_town_policy_menu", clCity.all_city_ids())
			if cityId < 0:
				return
			var vstateId = DataManager.vstates_sort[DataManager.vstate_no];
			var city = clCity.city(cityId)
			if city.get_vstate_id() in [-1, vstateId]:
				SceneManager.show_unconfirm_dialog("无法离间该城")
				return
			DataManager.common_variable["目标城"] = cityId
			FlowManager.add_flow("canvass_2")
		162: #招揽目标选择：武将列表
			if not wait_for_choose_actor("canvass_start"):
				return
			var targetId = SceneManager.actorlist.get_select_actor();
			var target = ActorHelper.actor(targetId)
			if target.get_loyalty() == 100:
				SceneManager.actorlist.speak("不可招揽君主")
				return;
			DataManager.common_variable["目标武将"] = target.actorId
			FlowManager.add_flow("canvass_3")
		163: #武将列表
			if not wait_for_choose_actor("enter_town_policy_menu"):
				return
			DataManager.player_choose_actor = SceneManager.actorlist.get_select_actor()
			if SkillHelper.auto_trigger_skill(DataManager.player_choose_actor, 10008, ""):
				return;
			FlowManager.add_flow("canvass_4")
		164: #命令书
			wait_for_yesno("canvass_5", "enter_town_menu")
		167:
			wait_for_confirmation("canvass_7")
	return

#--------(150)策略选项----------
func enter_town_policy_menu():
	LoadControl.set_view_model(150);
	var scene_affiars:Control = SceneManager.current_scene();
	scene_affiars.cursor.hide();
	DataManager.twinkle_citys = [DataManager.player_choose_city];
	SceneManager.hide_all_tool();
	var menu_array = ["同盟","离间","招揽","策反"]
	DataManager.common_variable["列表值"]=menu_array;
	DataManager.common_variable["列表页码"] = 0;
	SceneManager.lsc_menu.lsc.items = menu_array;
	SceneManager.lsc_menu.lsc.columns = 2;
	SceneManager.lsc_menu.set_lsc();
	SceneManager.lsc_menu.lsc._set_data();
	
	SceneManager.lsc_menu.show_msg("使用何种策略？");
	SceneManager.lsc_menu.show_orderbook(true);
	DataManager.cityInfo_type = 1;
	SceneManager.show_cityInfo(true);
	SceneManager.lsc_menu.show();
	return

#----------------------同盟------------------------
func alliance_menu():
	var currentVstateId = int(DataManager.vstates_sort[DataManager.vstate_no])
	var currentVstate = clVState.vstate(currentVstateId)
	var targetCityIds = []
	for vs in clVState.all_vstates():
		if vs.id == currentVstateId:
			continue
		if not vs.is_alive():
			continue
		var capital = clCity.get_capital_city(vs.id)
		if capital == null:
			continue
		targetCityIds.append(capital.ID)
	DataManager.set_env("同盟对象", targetCityIds)
	SceneManager.hide_all_tool()
	DataManager.twinkle_citys = []
	SceneManager.current_scene().cursor.show()
	SceneManager.current_scene().set_city_cursor_position(targetCityIds[0])
	LoadControl.set_view_model(121)
	return

#同盟：展示同盟界面(111)
func alliance_menu_old():
	var currentVstateId = int(DataManager.vstates_sort[DataManager.vstate_no])
	var currentVstate = clVState.vstate(currentVstateId)
	SceneManager.current_scene().cursor.hide();
	DataManager.twinkle_citys = [DataManager.player_choose_city];
	SceneManager.hide_all_tool();

	var vstates = []
	for vs in clVState.all_vstates():
		if vs.id == currentVstateId:
			continue
		if not vs.is_alive():
			continue
		vstates.append(vs)

	var maxPage = int((vstates.size() - 1) / pageSize)
	var page = DataManager.get_env_int("列表页码")
	if page < 0:
		page = maxPage
	if page > maxPage:
		page = 0
	DataManager.set_env("列表页码", page)
	var from = page * pageSize
	var to = min(vstates.size(), from + pageSize) - 1
	vstates = vstates.slice(from, to)

	var items = []
	var values = []
	for vs in vstates:
		var item = ActorHelper.actor(vs.get_lord_id()).get_name()
		var month = clVState.get_alliance_month(vs.id, currentVstateId)
		if(month==0):
			item+="  -----";
		else:
			item+="  "+str(month)+"月";
		items.append(item)
		values.append(vs.id)
	for i in range(items.size(), 14):
		items.append("")
		values.append("")
	if maxPage > 0:
		items.append("下一页")
		values.append(-1)
		items.append("上一页")
		values.append(-1)
	
	DataManager.set_env("列表值", values)
	SceneManager.show_unconfirm_dialog("向谁发起同盟？", currentVstate.get_lord_id());
	SceneManager.lsc_menu_top.lsc.items = items
	SceneManager.lsc_menu_top.lsc.columns = 2
	SceneManager.lsc_menu_top.set_lsc()
	SceneManager.lsc_menu_top.lsc._set_data()
	if maxPage > 0:
		SceneManager.lsc_menu_top.lsc.set_pager(page, maxPage)
	DataManager.cityInfo_type = 1
	SceneManager.show_cityInfo(false)
	SceneManager.lsc_menu_top.show()
	LoadControl.set_view_model(111)
	return

#判断同盟状态，是同盟还是撕毁
func alliance_2():
	DataManager.show_orderbook = true
	var currentVstateId = int(DataManager.vstates_sort[DataManager.vstate_no])
	var targetVstateId = int(DataManager.common_variable["目标势力"])
	var month = clVState.get_alliance_month(targetVstateId, currentVstateId)
	if month <= 0:
		FlowManager.add_flow("alliance_join_3")
	else:
		FlowManager.add_flow("alliance_break_3")
	LoadControl.set_view_model(112)
	return

#同盟
func alliance_join_3():
	var city = clCity.city(DataManager.player_choose_city)
	var targetVstateId = int(DataManager.common_variable["目标势力"])
	var msg = "何人前往说服{0}？".format([
		clVState.vstate(targetVstateId).get_lord_name()
	])
	SceneManager.show_actorlist_develop(city.get_actor_ids(), false, msg)
	LoadControl.set_view_model(113)
	return

#同盟：命令书
func alliance_join_4():
	SceneManager.show_yn_dialog("消耗1枚命令书可否")
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(114)
	return

#同盟：命令书消耗动画
func alliance_join_5():
	var city = clCity.city(DataManager.player_choose_city)
	OrderHistory.record_order(city.get_vstate_id(), "同盟", DataManager.player_choose_actor)
	SceneManager.dialog_use_orderbook_animation("alliance_join_6")
	return

#动画
func alliance_join_6():
	var cmd = DataManager.new_policy_command("同盟", DataManager.player_choose_actor)
	var targetVstateId = DataManager.get_env_int("目标势力")
	var capital = clCity.get_capital_city(targetVstateId)
	cmd.set_target(capital.get_lord_id(), capital.ID)
	cmd.prepare()

	var msg = "同盟成功率：{0}%".format([cmd.rate])
	if cmd.rate != cmd.basicRate:
		var signChar = "+"
		if cmd.rate < cmd.basicRate:
			signChar = "-"
		msg = "同盟成功率：{0}({1}{2})%".format([cmd.basicRate, signChar, cmd.rate - cmd.basicRate])
	SceneManager.play_affiars_animation(
		"Town_Ally", "", false, msg,
		cmd.actionId)
	LoadControl.set_view_model(116)
	return

#计算求盟结果
func alliance_join_7():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "同盟":
		FlowManager.add_flow("city_enter_menu")
		return

	cmd.execute()
	if cmd.result > 0:
		FlowManager.add_flow("alliance_join_success_1")
		return

	var d = cmd.pop_result_dialog()
	if d == null:
		DataManager.twinkle_citys = []
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("city_enter_menu")
		return
	DataManager.twinkle_citys = [d.cityId]
	SceneManager.show_confirm_dialog(d.msg, d.actorId, d.mood)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(116)
	return

#成功:告知玩家所需花费
func alliance_join_success_1():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "同盟":
		FlowManager.add_flow("city_enter_menu")
		return

	var resources = []
	if cmd.costGold > 0:
		resources.append("{0}两金".format([cmd.costGold]))
	if cmd.costRice > 0:
		resources.append("{0}石米".format([cmd.costRice]))
	var msg = "{0}大人\n{1}索要{2}\n是否给予？".format([
		cmd.city().get_lord_name(),
		cmd.target_vstate().get_lord_name(),
		"、".join(resources),
	])
	SceneManager.show_cityInfo(true)
	SceneManager.show_yn_dialog(msg, cmd.actionId)
	LoadControl.set_view_model(118)
	return

#成功:显示结果
func alliance_join_success_2():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "同盟":
		FlowManager.add_flow("city_enter_menu")
		return

	if cmd.city().get_gold() < cmd.costGold:
		LoadControl._affiars_error("现如今城内并无足够金\n请下达其他命令")
		return
	if cmd.city().get_rice() < cmd.costRice:
		LoadControl._affiars_error("现如今城内并无足够米\n请下达其他命令")
		return

	cmd.city().add_gold(-cmd.costGold)
	cmd.city().add_rice(-cmd.costRice)
	var allyMonths = Global.get_random(5, 12)
	clVState.set_alliance(cmd.vstate().id, cmd.target_vstate().id, allyMonths)

	var msg = "可喜可贺！\n成功与{0}结盟{1}月".format([
		cmd.target_vstate().get_lord_name(), allyMonths
	])
	SceneManager.show_confirm_dialog(msg, cmd.actionId)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(119)
	return

#撕毁
func alliance_break_3():
	var targetVstateId = DataManager.get_env_int("目标势力")
	var targetVstate = clVState.vstate(targetVstateId)
	var msg = "撕毁与{0}的盟约\n确定吗？".format([
		targetVstate.get_lord_name()
	])
	SceneManager.show_yn_dialog(msg)
	LoadControl.set_view_model(133)
	return
	
#撕毁盟约：命令书
func alliance_break_4():
	LoadControl.set_view_model(134);
	SceneManager.show_yn_dialog("消耗1枚命令书可否");
	SceneManager.show_cityInfo(true);

#撕毁盟约：命令书消耗动画
func alliance_break_5():
	var city = clCity.city(DataManager.player_choose_city)
	OrderHistory.record_order(city.get_vstate_id(), "毁盟", DataManager.player_choose_actor)
	SceneManager.dialog_use_orderbook_animation("alliance_break_6");

func alliance_break_6():
	LoadControl.set_view_model(136);
	var currentVstateId = int(DataManager.vstates_sort[DataManager.vstate_no]);
	var reporter = DataManager.get_max_property_actorId("政", currentVstateId)
	var targetVstateId = DataManager.get_env_int("目标势力")
	var targetVstate = clVState.vstate(targetVstateId)
	var msg = "已解除与{0}的盟约".format([targetVstate.get_lord_name()])
	SceneManager.show_confirm_dialog(msg, reporter)
	SceneManager.show_cityInfo(true);
	if(FlowManager.controlNo == AutoLoad.playerNo):
		clVState.set_alliance(currentVstateId, targetVstateId, 0)
	return

#----------------------离间------------------------
#离间:选城(151)
func wedge_start():
	SceneManager.clear_bottom()
	DataManager.twinkle_citys.clear()
	SceneManager.current_scene().cursor.show()
	var cityId = DataManager.player_choose_city
	var cmd = DataManager.get_current_policy_command()
	if cmd != null && cmd.type in ["离间", "招揽"]:
		cityId = cmd.targetCityId
	SceneManager.current_scene().set_city_cursor_position(cityId)
	SceneManager.show_unconfirm_dialog("离间哪座城池的武将？")
	LoadControl.set_view_model(151)
	return

#离间:目标城武将列表
func wedge_2():
	SceneManager.current_scene().cursor.hide()
	var targetCityId = DataManager.get_env_int("目标城")
	var cmd = DataManager.new_policy_command("离间", -1)
	cmd.set_target(-1, targetCityId)
	DataManager.twinkle_citys = [cmd.cityId, cmd.targetCityId]
	var msg = "此处为{0}，离间何人？".format([cmd.target_city().get_name()])
	SceneManager.show_actorlist_army(cmd.target_city().get_actor_ids(), false, msg, false)
	LoadControl.set_view_model(152)
	return

#离间:己方武将列表
func wedge_3():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "离间":
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("wedge_start")
		return
	var targetActorId = DataManager.get_env_int("目标武将")
	cmd.set_target(targetActorId, cmd.targetCityId)
	SceneManager.current_scene().cursor.hide()
	DataManager.twinkle_citys = [cmd.cityId, cmd.targetCityId]
	SceneManager.show_actorlist_develop(cmd.city().get_actor_ids(), false, "派遣何人？请指定")
	LoadControl.set_view_model(153)
	return

#命令书
func wedge_4():
	#命令书确认
	DataManager.show_orderbook = true
	SceneManager.show_yn_dialog("消耗1枚命令书可否")
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(154)
	return

#命令书消耗动画
func wedge_5():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "离间":
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("wedge_start")
		return
	OrderHistory.record_order(cmd.city().get_vstate_id(), "离间", cmd.actioner().actorId)
	SceneManager.dialog_use_orderbook_animation("wedge_6")
	return

#动画
func wedge_6():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "离间":
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("wedge_start")
		return
	cmd.set_actioner(DataManager.player_choose_actor)
	cmd.prepare()
	var msg = "已派出细作尝试离间\n（成功率：{0}%".format([cmd.rate])
	SceneManager.play_affiars_animation(
		"Town_Alienate", "", false, msg,
		cmd.actioner().actorId)
	LoadControl.set_view_model(157)
	return

#确认结果
func wedge_7():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "离间":
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("wedge_start")
		return

	cmd.execute()
	var d = cmd.pop_result_dialog()
	if d == null:
		DataManager.twinkle_citys = []
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("city_enter_menu")
		return
	DataManager.twinkle_citys = [d.cityId]
	SceneManager.show_confirm_dialog(d.msg, d.actorId, d.mood)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(157)
	return

#----------------------招揽------------------------
#招揽:选城(161)
func canvass_start():
	SceneManager.clear_bottom()
	DataManager.twinkle_citys.clear()
	SceneManager.current_scene().cursor.show()
	var cityId = DataManager.player_choose_city
	var cmd = DataManager.get_current_policy_command()
	if cmd != null && cmd.type in ["离间", "招揽"]:
		cityId = cmd.targetCityId
	SceneManager.current_scene().set_city_cursor_position(cityId)
	SceneManager.show_unconfirm_dialog("招揽哪座城池的武将？")
	LoadControl.set_view_model(161)
	return

#招揽:目标城武将列表
func canvass_2():
	SceneManager.current_scene().cursor.hide()
	var targetCityId = DataManager.get_env_int("目标城")
	var cmd = DataManager.new_policy_command("招揽", -1)
	cmd.set_target(-1, targetCityId)
	DataManager.twinkle_citys = [cmd.cityId, cmd.targetCityId]
	var msg = "此处为{0}，招揽何人？".format([cmd.target_city().get_name()])
	SceneManager.show_actorlist_army(cmd.target_city().get_actor_ids(), false, msg, false)
	LoadControl.set_view_model(162)
	return

#招揽:己方武将列表
func canvass_3():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "招揽":
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("canvass_start")
		return
	var targetActorId = DataManager.get_env_int("目标武将")
	cmd.set_target(targetActorId, cmd.targetCityId)
	SceneManager.current_scene().cursor.hide()
	DataManager.twinkle_citys = [cmd.cityId, cmd.targetCityId]
	SceneManager.show_actorlist_develop(cmd.city().get_actor_ids(), false, "派遣何人？请指定")
	LoadControl.set_view_model(163)
	return

#命令书
func canvass_4():
	#命令书确认
	DataManager.show_orderbook = true
	SceneManager.show_yn_dialog("消耗1枚命令书可否")
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(164)
	return

#命令书消耗动画
func canvass_5():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "招揽":
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("canvass_start")
		return
	OrderHistory.record_order(cmd.city().get_vstate_id(), "招揽", cmd.actioner().actorId)
	SceneManager.dialog_use_orderbook_animation("canvass_6")
	return

#动画
func canvass_6():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "招揽":
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("canvass_start")
		return
	cmd.set_actioner(DataManager.player_choose_actor)
	cmd.prepare()
	var msg = "已派出信使尝试招揽\n（成功率：{0}%".format([cmd.rate])
	SceneManager.play_affiars_animation(
		"Town_Canvass", "", false, msg,
		cmd.actioner().actorId)
	LoadControl.set_view_model(167)
	return

#确认结果
func canvass_7():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "招揽":
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("canvass_start")
		return

	cmd.execute()
	var d = cmd.pop_result_dialog()
	if d == null:
		DataManager.twinkle_citys = []
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("city_enter_menu")
		return
	DataManager.twinkle_citys = [d.cityId]
	SceneManager.show_confirm_dialog(d.msg, d.actorId, d.mood)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(167)
	return

#----------------------挑唆------------------------
#策反:选城(281)
func incite_start():
	SceneManager.clear_bottom()
	DataManager.twinkle_citys.clear()
	SceneManager.current_scene().cursor.show()
	var cityId = DataManager.player_choose_city
	var cmd = DataManager.get_current_policy_command()
	if cmd != null && cmd.type in ["离间", "策反"]:
		cityId = cmd.targetCityId
	SceneManager.current_scene().set_city_cursor_position(cityId)
	SceneManager.show_unconfirm_dialog("策反哪座城池的太守？")
	LoadControl.set_view_model(281)
	return

#策反:目标城武将列表
func incite_2():
	SceneManager.current_scene().cursor.hide()
	var targetCityId = DataManager.get_env_int("目标城")
	var cmd = DataManager.new_policy_command("策反", -1)
	cmd.set_target(-1, targetCityId)
	DataManager.twinkle_citys = [cmd.cityId, cmd.targetCityId]
	var msg = "此处为{0}，策反何人？".format([cmd.target_city().get_name()])
	SceneManager.show_actorlist_army(cmd.target_city().get_actor_ids(), false, msg, false)
	LoadControl.set_view_model(282)
	return

#策反:己方武将列表
func incite_3():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "策反":
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("incite_start")
		return
	var targetActorId = DataManager.get_env_int("目标武将")
	cmd.set_target(targetActorId, cmd.targetCityId)
	SceneManager.current_scene().cursor.hide()
	DataManager.twinkle_citys = [cmd.cityId, cmd.targetCityId]
	SceneManager.show_actorlist_develop(cmd.city().get_actor_ids(), false, "派遣何人？请指定")
	LoadControl.set_view_model(283)
	return

#命令书
func incite_4():
	#命令书确认
	DataManager.show_orderbook = true
	SceneManager.show_yn_dialog("消耗1枚命令书可否")
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(284)
	return

#命令书消耗动画
func incite_5():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "策反":
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("incite_start")
		return
	OrderHistory.record_order(cmd.city().get_vstate_id(), "策反", cmd.actioner().actorId)
	SceneManager.dialog_use_orderbook_animation("incite_6")
	return

#动画
func incite_6():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "策反":
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("incite_start")
		return

	cmd.set_actioner(DataManager.player_choose_actor)
	cmd.prepare()
	var msg = "已派出信使尝试策反\n（成功率：{0}%".format([cmd.rate])
	SceneManager.play_affiars_animation(
		"Town_Canvass", "", false, msg,
		cmd.actioner().actorId)
	LoadControl.set_view_model(287)
	return

#确认结果
func incite_7():
	SceneManager.cleanup_animations()
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "策反":
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("incite_start")
		return

	cmd.execute()
	var d = cmd.pop_result_dialog()
	if d == null:
		DataManager.twinkle_citys = []
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("city_enter_menu")
		return
	DataManager.twinkle_citys = [d.cityId]
	SceneManager.show_confirm_dialog(d.msg, d.actorId, d.mood)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(287)
	return
