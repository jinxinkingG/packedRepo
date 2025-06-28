extends "affairs_base.gd"

#情报搜集
func _init() -> void:
	LoadControl.view_model_name = "内政-玩家-步骤"

	FlowManager.bind_import_flow("search_start", self)
	FlowManager.bind_import_flow("search_actor_selected", self)
	FlowManager.bind_import_flow("search_confirmed", self)
	FlowManager.bind_import_flow("search_animation", self)
	FlowManager.bind_import_flow("search_go", self)
	FlowManager.bind_import_flow("search_execute", self)
	FlowManager.bind_import_flow("search_report", self)
	FlowManager.bind_import_flow("search_accept", self)
	FlowManager.bind_import_flow("search_done", self)

	# 所有旧流程的兼容
	for key in [
		"search_2", "search_3", "search_4",
		"search_5", "search_6", "search_6_trigger",
		"search_7", "search_7_actor_1", "search_7_actor_2",
		]:
		FlowManager.bind_signal_method(key, self, "search_fallback")

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
			FlowManager.add_flow("search_actor_selected")
		132: #命令书
			wait_for_yesno("search_confirmed", "enter_town_menu")
		134:
			wait_for_confirmation("search_go")
		137:
			wait_for_confirmation("search_report")
		138:
			wait_for_yesno("search_accept", "search_done")
		139:
			wait_for_confirmation("search_done")
	return

#情报搜集：选人
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
func search_actor_selected():
	#命令书确认
	SceneManager.show_yn_dialog("消耗1枚命令书可否")
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(132)
	return

#情报搜集：命令书消耗动画
func search_confirmed():
	SceneManager.dialog_use_orderbook_animation("search_animation")
	return

#情报搜集：动画
func search_animation():
	var cityId = DataManager.player_choose_city
	var actorId = DataManager.player_choose_actor
	var cmd = DataManager.new_search_command(cityId, actorId)
	cmd.update_special_actor_history()
	OrderHistory.record_order(cmd.vstateId, "搜索", cmd.fromId)
	DataManager.set_env("内政.上次搜索武将", cmd.fromId)
	DataManager.twinkle_citys = [cityId]
	var msg = "遵命，马上就去"
	if cmd.fromId == cmd.city().get_lord_id():
		msg = "既如此，马上就去"
	SceneManager.play_affiars_animation("Town_Search", "", false, msg, cmd.fromId)
	LoadControl.set_view_model(134)
	return

#计算搜索结果
func search_go():
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
	# 支持 flow
	if SkillHelper.auto_trigger_skill(cmd.fromId, 10017, "search_execute"):
		return
	FlowManager.add_flow("search_execute")
	return

func search_execute():
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
	FlowManager.add_flow("search_report")
	return

func search_report():
	var cmd = DataManager.get_current_search_command()
	if cmd == null or cmd.cityId != DataManager.player_choose_city:
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("search_start")
		return
	var d = cmd.next_dialog()
	if d == null:
		FlowManager.add_flow("search_done")
		return
	if d.yn > 0:
		SceneManager.show_yn_dialog(d.msg, d.actorId, d.mood)
		LoadControl.set_view_model(138)
	else:
		SceneManager.show_confirm_dialog(d.msg, d.actorId, d.mood)
		LoadControl.set_view_model(137)
	DataManager.twinkle_citys = [d.twinkleCityIds]
	#更新城池信息
	SceneManager.show_cityInfo(true)
	return
	
#情报搜集：确认结果提示
func search_accept():
	var cmd = DataManager.get_current_search_command()
	if cmd == null or cmd.cityId != DataManager.player_choose_city:
		FlowManager.add_flow("city_enter_menu")
		return
	if not cmd.result in [5,6,7] or cmd.foundActorId < 0:
		FlowManager.add_flow("search_done")
		return

	cmd.accept_actor()
	FlowManager.add_flow("search_report")
	return

func search_done() -> void:
	var cmd = DataManager.get_current_search_command()
	DataManager.set_env("内政.命令", "搜索")
	if SkillHelper.auto_trigger_skill(cmd.fromId, 10012, "city_enter_menu"):
		return
	FlowManager.add_flow("city_enter_menu")
	return

func search_fallback() -> void:
	FlowManager.add_flow("city_enter_menu")
	return
