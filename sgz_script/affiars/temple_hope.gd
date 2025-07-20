extends "affairs_base.gd"

#祈祷
func _init() -> void:
	LoadControl.view_model_name = "内政-玩家-步骤"

	FlowManager.bind_import_flow("hope_start", self)

	FlowManager.bind_import_flow("hope_unoffice_1", self)
	FlowManager.bind_import_flow("hope_unoffice_2", self)
	FlowManager.bind_import_flow("hope_unoffice_3", self)
	FlowManager.bind_import_flow("hope_unoffice_4", self)
	FlowManager.bind_import_flow("hope_unoffice_5", self)
	
	FlowManager.bind_import_flow("hope_revive_1", self)
	FlowManager.bind_import_flow("hope_revive_2", self)
	FlowManager.bind_import_flow("hope_revive_3", self)
	FlowManager.bind_import_flow("hope_revive_4", self)
	FlowManager.bind_import_flow("hope_revive_5", self)

	FlowManager.bind_import_flow("hope_summon_1", self)
	FlowManager.bind_import_flow("hope_summon_2", self)
	FlowManager.bind_import_flow("hope_summon_3", self)
	FlowManager.bind_import_flow("hope_summon_4", self)
	FlowManager.bind_import_flow("hope_summon_5", self)

	FlowManager.bind_import_flow("change_mode_1", self)
	FlowManager.bind_import_flow("change_mode_2", self)
	FlowManager.bind_import_flow("change_mode_3", self)
	FlowManager.bind_import_flow("change_mode_4", self)
	FlowManager.bind_import_flow("change_mode_5", self)
	FlowManager.bind_import_flow("change_mode_6", self)

	FlowManager.bind_import_flow("hope_star_1", self)
	FlowManager.bind_import_flow("hope_star_2", self)
	FlowManager.bind_import_flow("hope_star_3", self)
	FlowManager.bind_import_flow("hope_star_4", self)
	FlowManager.bind_import_flow("hope_star_5", self)

	return

#按键操控
func _input_key(delta: float):
	var scene_affiars:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var top = SceneManager.lsc_menu_top;
	var view_model = LoadControl.get_view_model();
	match view_model:
		180:
			var prayOptions = ["hope_unoffice_1", "hope_revive_1", "hope_summon_1", "change_mode_1"]
			DataManager.set_env("内政.复活.翻页", 0)
			wait_for_options(prayOptions, "enter_temple_menu")
		181:
			if(Input.is_action_just_pressed("ANALOG_UP")):
				top.lsc.move_up();
			if(Input.is_action_just_pressed("ANALOG_DOWN")):
				top.lsc.move_down();
			if(Input.is_action_just_pressed("ANALOG_LEFT")):
				top.lsc.move_left();
			if(Input.is_action_just_pressed("ANALOG_RIGHT")):
				top.lsc.move_right();
			var value_array = DataManager.get_env_array("列表值")
			var value:String = value_array[top.lsc.cursor_index]
			var currentActorId = int(value.split("_")[1])
			if currentActorId >= 0:
				SceneManager.show_simply_actor_info(currentActorId, "提前哪位的出仕年份？")
				SceneManager.lsc_menu_top.show()
			else:
				SceneManager.actor_info.hide()
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				DataManager.set_env("值", value)
				FlowManager.add_flow("hope_unoffice_2")
			if(Global.is_action_pressed_BY()):
				if(!bottom.is_msg_complete()):
					return;
				FlowManager.add_flow("hope_start");
		182:
			wait_for_confirmation("hope_unoffice_3", "enter_temple_menu")
		183:
			wait_for_yesno("hope_unoffice_4", "city_enter_menu")
		185:
			wait_for_confirmation()
		191:
			if(Global.is_action_pressed_BY()):
				if(!bottom.is_msg_complete()):
					return;
				FlowManager.add_flow("hope_start");
			if(Input.is_action_just_pressed("ANALOG_UP")):
				top.lsc.move_up();
			if(Input.is_action_just_pressed("ANALOG_DOWN")):
				top.lsc.move_down();
			if(Input.is_action_just_pressed("ANALOG_LEFT")):
				top.lsc.move_left();
			if(Input.is_action_just_pressed("ANALOG_RIGHT")):
				top.lsc.move_right();
			var values = DataManager.get_env_array("列表值")
			var value:String = str(values[top.lsc.cursor_index])
			var currentActorId = int(value.split("_")[0])
			if currentActorId >= 0:
				SceneManager.show_simply_actor_info(currentActorId, "复活何人？")
				SceneManager.lsc_menu_top.show()
			else:
				SceneManager.actor_info.hide()
			if Global.is_action_pressed_AX():
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				if currentActorId < 0:
					var pageDiff = int(value.split("_")[1])
					DataManager.set_env("内政.复活.翻页", DataManager.get_env_int("内政.复活.翻页") + pageDiff)
					FlowManager.add_flow("hope_revive_1")
					return
				DataManager.set_env("值", value)
				FlowManager.add_flow("hope_revive_2");
		192:
			wait_for_confirmation("hope_revive_3", "enter_temple_menu")
		193:
			wait_for_yesno("hope_revive_4", "city_enter_menu")
		195:
			wait_for_confirmation()
		231:
			wait_for_confirmation("hope_summon_2", "enter_temple_menu")
		232:
			wait_for_yesno("hope_summon_3", "city_enter_menu")
		234:
			wait_for_confirmation("hope_summon_5")
		235:
			wait_for_confirmation()
		271:
			wait_for_yesno("change_mode_2", "hope_start")
		272:
			wait_for_yesno("change_mode_4", "change_mode_6")
		273:
			wait_for_confirmation("change_mode_5")
		281:
			wait_for_confirmation("hope_star_2", "enter_temple_menu")
		282:
			wait_for_yesno("hope_star_3", "city_enter_menu")
		284:
			wait_for_confirmation("hope_star_5")
		285:
			wait_for_confirmation()
	return

#--------(180)祈祷----------
func hope_start():
	#发展到一定程度，解锁【祈祷】
	var city = clCity.city(DataManager.player_choose_city)
	var unlocked = false
	if not unlocked and DataManager.is_test_player():
		unlocked = true
	if not unlocked and city.well_developed():
		unlocked = true
	if not unlocked and SkillRangeBuff.max_val_for_city("解锁祈祷", city.ID) > 0:
		unlocked = true
	if not unlocked:
		LoadControl._affiars_error("城市开发不足\n需 999/999/50000 解锁");
		return

	var scene_affiars:Control = SceneManager.current_scene();
	scene_affiars.cursor.hide();
	DataManager.twinkle_citys = [city.ID];
	SceneManager.hide_all_tool();
	var menu = ["提前出仕","复活武将","召唤异士","修改模式"]
	if DataManager.is_stars_drama():
		# 星耀剧本特殊规则
		menu[2] = "禳星回生"
	
	DataManager.set_env("列表值", menu)
	
	SceneManager.lsc_menu.lsc.items = menu
	SceneManager.lsc_menu.lsc.columns = 2;
	SceneManager.lsc_menu.set_lsc()
	SceneManager.lsc_menu.lsc._set_data();
	
	SceneManager.lsc_menu.show_msg("祈祷何事？")
	SceneManager.lsc_menu.show_orderbook(true)
	DataManager.cityInfo_type = 1
	SceneManager.show_cityInfo(true)
	SceneManager.lsc_menu.show()
	LoadControl.set_view_model(180)
	return

#提前出仕
func hope_unoffice_1():
	LoadControl.set_view_model(181);
	var scene_affiars:Control = SceneManager.current_scene();
	scene_affiars.cursor.hide();
	var words = {};
	var value_array:Array = [];
	# 本城优先
	var current_city_key:String = ""
	# 本城跟随优先
	var cityActors = clCity.city(DataManager.player_choose_city).get_actor_ids()
	var current_parent_key:String = ""
	
	#在野
	var unoffices = Array(DataManager.citys_unoffice).duplicate(true);
	unoffices.shuffle();
	for dic in unoffices:
		var actorId = dic["武将"];
		var actor = ActorHelper.actor(actorId)
		if not actor.is_status_unofficed():
			continue
		var appearYear = actor.get_appear_year(int(dic["登场年"]))
		if appearYear <= DataManager.year:
			continue
		var inCity = clCity.city(int(dic["城池"]))
		var key = "{0}_{1}_{2}".format([appearYear, actorId, inCity.ID]);
		if current_city_key == "" and inCity.ID == DataManager.player_choose_city:
			current_city_key = key
		value_array.append(key);
		words[key]="{0} {1} {2}".format([inCity.get_name(), appearYear, actor.get_name()]);
	
	#跟随
	var follows = Array(DataManager.actor_follower).duplicate(true);
	follows.shuffle();
	for dic in follows:
		var childId = dic["子将"];
		var child = ActorHelper.actor(childId)
		if not child.is_status_unofficed():
			continue
		var appearYear = child.get_appear_year(int(dic["登场年"]))
		if appearYear <= DataManager.year:
			continue
		var key = "{0}_{1}_{2}".format([appearYear, childId, "跟随"+str(dic["父将"])]);
		if current_parent_key == "" and int(dic["父将"]) in cityActors:
			current_parent_key = key
		value_array.append(key);
		words[key]="{0} {1} {2}".format(["跟随", appearYear, child.get_name()]);
	
	value_array.erase(current_city_key)
	value_array.erase(current_parent_key)
	value_array.shuffle();
	value_array = value_array.slice(0,13);
	value_array.sort()
	if current_parent_key != "":
		value_array.push_front(current_parent_key)
	if current_city_key != "":
		value_array.push_front(current_city_key)
	value_array = value_array.slice(0,13);
	var menu_array = [];
	for ya in value_array:
		menu_array.append(words[ya]);

	SceneManager.hide_all_tool();
	if(value_array.empty()):
		LoadControl._affiars_error("当前全武将都可搜寻\n无需提前");
		return;
	SceneManager.show_unconfirm_dialog("提前哪位在野\n人员的出仕年份？");
	SceneManager.lsc_menu_top.lsc.columns = 2;
	SceneManager.lsc_menu_top.lsc.items = menu_array;
	DataManager.common_variable["列表值"]=value_array;
	SceneManager.lsc_menu_top.set_lsc()
	SceneManager.lsc_menu_top.lsc._set_data(30)
	
	SceneManager.lsc_menu_top.show();

#确认
func hope_unoffice_2():
	LoadControl.set_view_model(182);
	var value:String = str(DataManager.common_variable["值"]);
	var year = int(value.split("_")[0]);
	var actorId = int(value.split("_")[1]);
	var actor = ActorHelper.actor(actorId)
	var cost = max(0,year-DataManager.year)*100;#花费金额
	SceneManager.show_confirm_dialog("欲使{0}提前出仕\n需{1}两金".format([actor.get_name(),cost]),-5);
	SceneManager.show_cityInfo(true);
	DataManager.common_variable["价格"] = cost;
	
#命令书
func hope_unoffice_3():
	var cost = int(DataManager.common_variable["价格"]);#花费金额
	var city = clCity.city(DataManager.player_choose_city)
	if city.get_gold() < cost:
		LoadControl._affiars_error("汝心不诚\n如何可行？",-5);
		return;
	
	LoadControl.set_view_model(183);
	#命令书确认
	SceneManager.show_yn_dialog("消耗1枚命令书可否");
	SceneManager.show_cityInfo(true);
	
#命令书消耗动画
func hope_unoffice_4():
	LoadControl.set_view_model(184);
	SceneManager.dialog_use_orderbook_animation("hope_unoffice_5");

func hope_unoffice_5():
	LoadControl.set_view_model(185);
	var value:String = str(DataManager.common_variable["值"]);
	var year = int(value.split("_")[0]);
	var actorId = int(value.split("_")[1]);
	
	
	var actor = ActorHelper.actor(actorId)
	var cost = int(DataManager.common_variable["价格"]);#花费金额
	var city = clCity.city(DataManager.player_choose_city)
	city.add_gold(-cost)
	actor.set_new_appear_year(DataManager.year)
	DataManager.fix_data(true);
	
	if("跟随" in value.split("_")[2]):
		var fid = int(str(value.split("_")[2]).replace("跟随",""));
		var father = ActorHelper.actor(fid)
		SceneManager.show_confirm_dialog("{0}已经可以跟随{1}出仕了".format([
			actor.get_name(), father.get_name()
		]),-5);
	else:
		var inCityId = int(value.split("_")[2]);
		var inCity = clCity.city(inCityId)
		SceneManager.show_confirm_dialog("{0}在{1}已经可以搜索了".format([
			actor.get_name(), inCity.get_name()
		]),-5);
	SceneManager.show_cityInfo(true)
	return

#复活吧！我的爱人
func hope_revive_1():
	var dead = ActorHelper.all_dead_actors()
	if dead.empty():
		LoadControl._affiars_error("无人阵亡", -5, 1)
		return
	dead.sort_custom(ActorHelper, "_sort_actor_by_name")
	var page = DataManager.get_env_int("内政.复活.翻页")
	var maxPage = int((dead.size() - 1) / 10)
	if page < 0:
		page = maxPage
	if page > maxPage:
		page = 0
	DataManager.set_env("内政.复活.翻页", page)
	dead = dead.slice(page * 10, min(dead.size() - 1, page * 10 + 9))
	var items = []
	var values = []
	for actor in dead:
		var lifeLimit = actor.get_life_limit()
		var cost = max(0, DataManager.year - lifeLimit) * 100 + 1000
		var bargain = SkillRangeBuff.min_for_city("复活折扣", DataManager.player_choose_city, -1)
		if bargain > 0:
			cost = int(cost * bargain)
		items.append("{0} /{1}金".format([actor.get_name(), cost]))
		values.append("{0}_{1}_{2}".format([actor.actorId, lifeLimit, cost]))
	for i in range(items.size(), 12):
		items.append("")
		values.append("")
	if maxPage > 0:
		items.append("下一页")
		values.append("-1_1_0")
		items.append("上一页")
		values.append("-1_-1_0")
	if items.empty():
		LoadControl._affiars_error("当前不存在死亡武将")
		return
	SceneManager.current_scene().cursor.hide()
	SceneManager.hide_all_tool()
	SceneManager.show_simply_actor_info(int(values[0].split("_")[0]), "复活何人？")
	SceneManager.lsc_menu_top.lsc.columns = 2
	SceneManager.lsc_menu_top.lsc.items = items
	DataManager.set_env("列表值", values)
	SceneManager.lsc_menu_top.set_lsc()
	SceneManager.lsc_menu_top.lsc._set_data(30)
	if maxPage > 0:
		SceneManager.lsc_menu_top.lsc.set_pager(page, maxPage)
	SceneManager.lsc_menu_top.show()
	LoadControl.set_view_model(191)
	return

#确认
func hope_revive_2():
	LoadControl.set_view_model(192);
	var value:String = str(DataManager.common_variable["值"]);
	var actorId = int(value.split("_")[0]);
	var auto_dead_year = int(value.split("_")[1]);#大限年份
	var actor = ActorHelper.actor(actorId)
	var cost = int(value.split("_")[2]);#花费金额
	SceneManager.show_confirm_dialog("欲使{0}复活\n需{1}两金".format([actor.get_name(),cost]),-5);
	SceneManager.show_cityInfo(true);
	DataManager.common_variable["价格"] = cost;

#命令书
func hope_revive_3():
	var cost = int(DataManager.common_variable["价格"]);#花费金额
	var city = clCity.city(DataManager.player_choose_city)
	if city.get_gold() < cost:
		LoadControl._affiars_error("汝心不诚\n如何可行？",-5);
		return;

	LoadControl.set_view_model(193);
	#命令书确认
	SceneManager.show_yn_dialog("消耗1枚命令书可否");
	SceneManager.show_cityInfo(true);
	
#命令书消耗动画
func hope_revive_4():
	LoadControl.set_view_model(194);
	SceneManager.dialog_use_orderbook_animation("hope_revive_5");

func hope_revive_5():
	var value:String = str(DataManager.common_variable["值"]);
	var actorId = int(value.split("_")[0]);
	
	var actor = ActorHelper.actor(actorId)
	var cost = DataManager.get_env_int("价格")
	var city = clCity.city(DataManager.player_choose_city)
	var lord = ActorHelper.actor(city.get_lord_id())
	city.add_gold(-cost)
	actor.set_hp(10)
	actor.set_loyalty(Global.get_random(40, 40 + int(lord.get_loyalty() / 6)))
	#复活后不会在今年老死
	actor.set_life_limit(max(actor.get_life_limit(), DataManager.year + 1))
	var least_year = actor.get_life_limit() - DataManager.year
	var msg = "{0}在{1}及附近城\n可以搜索了\n其大限剩余{2}年"
	if not actor.set_status_exiled(-1, city.ID):
		# 未流放成功
		msg = "{0}已成功复活\n其大限剩余{2}年"
	msg = msg.format([
		actor.get_name(), city.get_name(), least_year
	])
	SceneManager.play_affiars_animation("Town_Save", "", false, msg, -5)
	LoadControl.set_view_model(195)
	return

#神！听从我的呼唤！
func hope_summon_1():
	if DataManager.is_stars_drama():
		# 星耀剧本特殊逻辑
		FlowManager.add_flow("hope_star_1")
		return
	var candidates = []
	for actor in ActorHelper.all_hidden_actors():
		candidates.append(actor.actorId)
	SceneManager.hide_all_tool()
	if candidates.empty():
		LoadControl._affiars_error("当前不存在可召唤的异士");
		return;
	var msg = "进行一次异士召唤\n需{0}两金".format([StaticManager.YISHI_COST])
	SceneManager.show_confirm_dialog(msg, -5)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(231)
	return

func hope_summon_2():
	var city = clCity.city(DataManager.player_choose_city)
	if city.get_gold() < StaticManager.YISHI_COST:
		LoadControl._affiars_error("汝心不诚\n如何可行？", -5)
		return

	#命令书确认
	SceneManager.show_yn_dialog("消耗1枚命令书可否")
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(232)
	return

func hope_summon_3():
	SceneManager.dialog_use_orderbook_animation("hope_summon_4")
	LoadControl.set_view_model(233)
	return

func hope_summon_4():
	var candidates = []
	for actor in ActorHelper.all_hidden_actors():
		candidates.append(actor.actorId)
	candidates.shuffle()
	var actorId = candidates[0]
	DataManager.set_env("武将", actorId)
	var actor = ActorHelper.actor(actorId)
	
	var cost = StaticManager.YISHI_COST
	var city = clCity.city(DataManager.player_choose_city)
	city.add_gold(-cost)
	
	#武将加入城中
	clCity.move_to(actorId, city.ID)
	actor.set_status_officed()
	actor.set_exile_city(city.ID)
	actor.set_life_limit(max(355, actor.get_life_limit()))

	SoundManager.play_anim_bgm("res://resource/sounds/se/Strategy02.ogg")
	SceneManager.show_confirm_dialog("{0}响应了你的召唤！".format([actor.get_name()]), -5, 1)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(234)
	return

func hope_summon_5():
	var actorId = DataManager.get_env_int("武将")
	SceneManager.show_confirm_dialog("愿效犬马之劳！", actorId)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(235)
	return

# 修改游戏模式
func change_mode_1():
	var msgs = []
	msgs.append("将进入修改游戏模式界面")
	msgs.append("[开始]键生效并回到游戏")
	msgs.append("注意：关闭监狱则俘虏下野")
	SceneManager.show_yn_dialog("\n".join(msgs))
	LoadControl.set_view_model(271)

func change_mode_2():
	DataManager.set_env("修改游戏模式", 1)
	DataManager.set_env("原游戏模式", DataManager.game_set.duplicate(true))
	SceneManager.hide_all_tool()
	LoadControl.end_script()
	FlowManager.add_flow("go_to_scene|res://scene/scene_set/scene_set.tscn")
	return

func change_mode_3():
	LoadControl.set_view_model(-1)
	var originalGameSetting = DataManager.get_env_dict("原游戏模式")
	if originalGameSetting["监狱系统"] != "无" and DataManager.get_game_setting("监狱系统") == "无":
		SceneManager.show_yn_dialog("将监狱系统改为「无」\n将导致所有俘虏下野\n请慎重，确定吗？")
		SceneManager.actor_dialog.lsc.cursor_index = 1
		LoadControl.set_view_model(272)
		return
	change_mode_4()
	return

func change_mode_4():
	LoadControl.set_view_model(-1)
	var originalGameSetting = DataManager.get_env_dict("原游戏模式")
	DataManager.unset_env("原游戏模式")
	var msgs = []
	for key in DataManager.game_set:
		var current = DataManager.get_game_setting(key)
		if not key in originalGameSetting or current != originalGameSetting[key]:
			msgs.append("{0}已修改为：{1}".format([key, current]))
	if originalGameSetting["监狱系统"] != "无" and DataManager.game_set["监狱系统"] == "无":
		while msgs.size() % 3 != 0:
			msgs.append("")
		var names = []
		var cnt = 0
		for city in clCity.all_cities():
			for actorId in city.get_ceil_actor_ids():
				clCity.move_out(actorId)
				var actor = ActorHelper.actor(actorId)
				actor.set_status_exiled(-1, city.ID)
				actor.set_loyalty(50)
				actor.set_dislike_vstate_id(city.get_vstate_id())
				if names.size() < 9:
					names.append(actor.get_name())
				cnt += 1
		if cnt > 0:
			names[names.size() - 1] += "等{0}人已被流放".format([cnt])
			var msg = "、".join(names)
			while msg.length() > 12:
				msgs.append(msg.left(12))
				msg = msg.right(12)
			if not msg.empty():
				msgs.append(msg)
	DataManager.set_env("修改模式结果", msgs)
	change_mode_5()
	return

func change_mode_5():
	LoadControl.set_view_model(-1)
	var msgs = DataManager.get_env_array("修改模式结果")
	if msgs.empty():
		DataManager.unset_env("修改模式结果")
		FlowManager.add_flow("city_enter_menu")
		return
	var msg = "\n".join(msgs)
	if msgs.size() > 3:
		msg = "\n".join(msgs.slice(0, 2))
		DataManager.set_env("修改模式结果", msgs.slice(3, msgs.size() - 1))
	else:
		DataManager.set_env("修改模式结果", [])
	SceneManager.show_confirm_dialog(msg)
	LoadControl.set_view_model(273)
	return

func change_mode_6():
	LoadControl.set_view_model(-1)
	var originalGameSetting = DataManager.get_env_dict("原游戏模式")
	DataManager.unset_env("原游戏模式")
	DataManager.game_set = originalGameSetting.duplicate(true)
	SceneManager.show_confirm_dialog("已取消选项修改\n沿用之前的游戏模式")
	DataManager.set_env("修改模式结果", [])
	LoadControl.set_view_model(273)
	return

#星耀版本的复活
func hope_star_1():
	if not DataManager.is_stars_drama():
		FlowManager.add_flow("player_ready")
		return
	var candidates = ActorHelper.all_dead_actors()
	SceneManager.hide_all_tool()
	if candidates.empty():
		LoadControl._affiars_error("漫天将星闪耀，并无陨落")
		return;
	SceneManager.show_confirm_dialog("进行一次禳星\n需 1000 两金", -5)
	SceneManager.show_cityInfo(true)
	DataManager.set_env("价格", 1000)
	LoadControl.set_view_model(281)
	return

func hope_star_2():
	if not DataManager.is_stars_drama():
		FlowManager.add_flow("player_ready")
		return
	var cost = DataManager.get_env_int("价格")
	var city = clCity.city(DataManager.player_choose_city)
	if city.get_gold() < cost:
		LoadControl._affiars_error("汝心不诚\n如何可行？", -5)
		return

	#命令书确认
	SceneManager.show_yn_dialog("消耗1枚命令书可否")
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(282)
	return

func hope_star_3():
	if not DataManager.is_stars_drama():
		FlowManager.add_flow("player_ready")
		return
	SceneManager.dialog_use_orderbook_animation("hope_star_4")
	LoadControl.set_view_model(283)
	return

func hope_star_4():
	var cost = DataManager.get_env_int("价格")
	var city = clCity.city(DataManager.player_choose_city)
	city.add_gold(-cost)

	# 模拟搜索确定武将加入的行为
	var candidates = ActorHelper.all_dead_actors()
	candidates.shuffle()
	var actor = candidates[0]
	var cmd = SearchCommand.new(city.ID, city.get_lord_id())
	cmd.force_actor_join(actor.actorId)
	var d = cmd.next_dialog()
	DataManager.set_env("武将", d.actorId)
	DataManager.set_env("对话", d.msg)
	DataManager.set_env("表情", d.mood)
	actor.set_hp(actor.get_max_hp())
	# 武将大限延长
	actor.set_life_limit(max(DataManager.year + 12, actor.get_life_limit()))

	SoundManager.play_anim_bgm("res://resource/sounds/se/Strategy02.ogg")
	SceneManager.show_confirm_dialog("{0}响应了你的召唤！".format([actor.get_name()]), -5, 1)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(284)
	return

func hope_star_5():
	var actorId = DataManager.get_env_int("武将")
	var msg = DataManager.get_env_str("对话")
	var mood = DataManager.get_env_int("表情")
	SceneManager.show_confirm_dialog(msg, actorId, mood)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(285)
	return
