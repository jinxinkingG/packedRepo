extends "affairs_base.gd"

#情报搜集
func _init() -> void:
	LoadControl.view_model_name = "内政-玩家-步骤"
	FlowManager.bind_signal_method("search_start", self)
	FlowManager.bind_signal_method("search_2", self)
	FlowManager.bind_signal_method("search_3", self)
	FlowManager.bind_signal_method("search_4", self)
	FlowManager.bind_signal_method("search_5", self)
	FlowManager.bind_signal_method("search_6", self)
	FlowManager.bind_signal_method("search_6_trigger", self)
	FlowManager.bind_signal_method("search_7", self)
	FlowManager.bind_signal_method("search_7_actor_1", self)
	FlowManager.bind_signal_method("search_7_actor_2", self)
	FlowManager.bind_signal_method("search_done", self)
	
	FlowManager.clear_pre_history.append("search_7")
	return

#按键操控
func _input_key(delta: float):
	var scene_affiars:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	match view_model:
		131: #搜索流程：选择武将
			if not wait_for_choose_actor("enter_town_menu"):
				return
			var actorId = SceneManager.actorlist.get_select_actor();
			DataManager.player_choose_actor = actorId
			if SkillHelper.auto_trigger_skill(actorId, 10008, ""):
				return
			FlowManager.add_flow("search_2")
		132: #命令书
			wait_for_yesno("search_3", "enter_town_menu")
		135:
			wait_for_confirmation("search_6")
		137:
			wait_for_confirmation("search_7_actor_1")
		138:
			wait_for_yesno("search_7_actor_2", "search_done")
		139:
			wait_for_confirmation("search_done")
	return

#情报搜集：选人(131)
func search_start():
	SceneManager.current_scene().cursor.hide()
	var cityId = DataManager.player_choose_city
	var city = clCity.city(cityId)
	var lastSelectedActorId = DataManager.get_env_int("内政.上次搜索武将", -1)
	var actorIds = city.get_actor_ids()
	SceneManager.show_actorlist_develop(actorIds, false, "派遣何人？请指定")
	var lastSelectedIdx = actorIds.find(lastSelectedActorId)
	if lastSelectedIdx >= 0:
		SceneManager.actorlist.move_to(lastSelectedIdx)
	DataManager.twinkle_citys = [cityId]
	LoadControl.set_view_model(131)
	return

#情报搜集：消耗命令书
func search_2():
	#命令书确认
	SceneManager.show_yn_dialog("消耗1枚命令书可否")
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(132)
	return

#情报搜集：命令书消耗动画
func search_3():
	SceneManager.dialog_use_orderbook_animation("search_4")
	LoadControl.set_view_model(-1)
	return

#情报搜集：动画
func search_4():
	var cityId = DataManager.player_choose_city
	var actorId = DataManager.player_choose_actor
	var cmd = DataManager.new_search_command(cityId, actorId)
	cmd.update_special_actor_history()
	OrderHistory.record_order(cmd.vstateId, "搜索", cmd.fromId)
	DataManager.set_env("内政.上次搜索武将", cmd.fromId)
	DataManager.twinkle_citys = [cityId]
	var msg = "遵命，马上就去"
	DataManager.set_env("对话", msg)
	SceneManager.show_unconfirm_dialog(msg)
	SceneManager.play_affiars_animation("Town_Search", "search_5")
	LoadControl.set_view_model(-1)
	return

#结果出现前确认
func search_5():
	var cmd = DataManager.get_current_search_command()
	if cmd == null or cmd.cityId != DataManager.player_choose_city:
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("search_start")
		return
	var msg = DataManager.get_env_str("对话")
	DataManager.twinkle_citys = [cmd.cityId]
	SceneManager.show_confirm_dialog(msg)
	SceneManager.dialog_msg_complete(true)
	#更新城池信息
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(135)
	return

#开始计算结果
func search_6():
	var cmd = DataManager.get_current_search_command()
	if cmd == null or cmd.cityId != DataManager.player_choose_city:
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("search_start")
		return
	if FlowManager.controlNo != AutoLoad.playerNo:
		#非当前玩家不进行计算
		return
	SoundManager.play_bgm("", true, true)
	cmd.decide_result()
	LoadControl.set_view_model(136)
	# 支持 flow
	if SkillHelper.auto_trigger_skill(cmd.fromId, 10017, "search_6_trigger"):
		return
	FlowManager.add_flow("search_6_trigger")
	return

func search_6_trigger():
	var cmd = DataManager.get_current_search_command()
	if cmd == null or cmd.cityId != DataManager.player_choose_city:
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("search_start")
		return
	# 测试找人时 uncomment 下面这行
	#cmd.result = 5
	cmd.execute()
	# 测试找人时 uncomment 下面这行
	#cmd.foundActorId = 364
	FlowManager.add_flow("search_7")
	return
	
#情报搜集:结果提示(1)
func search_7():
	var cmd = DataManager.get_current_search_command()
	if cmd == null or cmd.cityId != DataManager.player_choose_city:
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("search_start")
		return
	SceneManager.show_confirm_dialog(cmd.get_message(), cmd.fromId, cmd.mood)
	DataManager.twinkle_citys = [cmd.cityId]
	#更新城池信息
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(137)
	return
	
#情报搜集：结果提示仅武将(1)
func search_7_actor_1():
	var cmd = DataManager.get_current_search_command()
	if cmd == null or cmd.cityId != DataManager.player_choose_city:
		FlowManager.add_flow("city_enter_menu")
		return
	if not cmd.result in [5,6,7] or cmd.foundActorId < 0:
		FlowManager.add_flow("search_done")
		return

	cmd.decide_actor_result()
	if cmd.result == 9:
		# 加入技能判断，如【解仇】等
		for city in clCity.all_cities([cmd.vstateId]):
			for actorId in city.get_actor_ids():
				if SkillHelper.auto_trigger_skill(actorId, 10015, ""):
					return
		SceneManager.show_confirm_dialog(cmd.actorMessage, cmd.actorReporter, cmd.actorMood)
		LoadControl.set_view_model(139)
		return
	if cmd.result == 10:
		# 加入技能判断，如【荐才】【天子】等
		for city in clCity.all_cities([cmd.vstateId]):
			for actorId in city.get_actor_ids():
				if SkillHelper.auto_trigger_skill(actorId, 10005, ""):
					return
		SceneManager.show_confirm_dialog(cmd.actorMessage, cmd.actorReporter, cmd.actorMood)
		LoadControl.set_view_model(139)
		return

	if cmd.actorAsking:
		SceneManager.show_yn_dialog(cmd.actorMessage, cmd.actorReporter, cmd.actorMood)
	else:
		SceneManager.show_confirm_dialog(cmd.actorMessage, cmd.actorReporter, cmd.actorResponseMood)
	DataManager.twinkle_citys = [cmd.cityId]
	#更新城池信息
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(138)
	return

#情报搜集：结果提示仅武将(2)
func search_7_actor_2():
	var cmd = DataManager.get_current_search_command()
	if cmd == null or cmd.cityId != DataManager.player_choose_city:
		FlowManager.add_flow("search_done")
		return
	if not cmd.result in [5,6,7] or cmd.foundActorId < 0:
		FlowManager.add_flow("search_done")
		return
	# 被拒绝了，直接结束
	if cmd.actorJoin == 0:
		FlowManager.add_flow("search_done")
		return

	cmd.accept_actor()
	SceneManager.show_confirm_dialog(cmd.actorResponse, cmd.actorResponser, cmd.actorResponseMood)
	DataManager.twinkle_citys = [cmd.cityId]
	#更新城池信息
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(139)
	return

func search_done() -> void:
	var cmd = DataManager.get_current_search_command()
	DataManager.set_env("内政.命令", "搜索")
	if SkillHelper.auto_trigger_skill(cmd.fromId, 10012, "city_enter_menu"):
		return
	FlowManager.add_flow("city_enter_menu")
	return
