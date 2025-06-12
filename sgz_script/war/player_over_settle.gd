extends "war_base.gd"

#玩家结算界面
func _init() -> void:
	LoadControl.view_model_name = "战争-玩家-步骤";
	FlowManager.bind_import_flow("settle_start", self)
	FlowManager.bind_import_flow("settle_2", self)
	FlowManager.bind_import_flow("settle_3", self)
	FlowManager.bind_import_flow("settle_4", self)
	FlowManager.bind_import_flow("settle_5", self)
	FlowManager.bind_import_flow("settle_resource_report", self)
	FlowManager.bind_import_flow("endless_settle_2", self)
	FlowManager.bind_import_flow("endless_equip", self)
	FlowManager.bind_import_flow("endless_school", self)
	FlowManager.bind_import_flow("war_equip_done", self)
	FlowManager.bind_import_flow("war_school_done", self)
	return

#按键操控
func _input_key(delta: float):
	var wf = DataManager.get_current_war_fight()
	match LoadControl.get_view_model():
		1001:
			if not Global.is_action_pressed_AX():
				return
			if not SceneManager.dialog_msg_complete(true):
				return
			LoadControl.set_view_model(-1)
			var vstateId = DataManager.get_env_int("战争.结算方")
			var wv = wf.get_war_vstate(vstateId)
			if wv.lost():
				if DataManager.endless_model:
					FlowManager.add_flow("war_over_end")
				else:
					FlowManager.add_flow("settle_2")
				return
			if DataManager.endless_model:
				DataManager.set_env("值", 0)
				FlowManager.add_flow("endless_settle_2")
				return
			FlowManager.add_flow("war_over_end")
		1002:
			wait_for_confirmation("settle_3")
		1003:
			if wait_for_options([], ""):
				var option = SceneManager.lsc_menu.lsc.cursor_index
				var values = DataManager.get_env_int_array("列表值")
				var cityId = values[option]
				DataManager.set_env("值", cityId)
				FlowManager.add_flow("settle_4")
		1004:
			wait_for_confirmation("settle_5")
		1005:
			var actorIds = DataManager.get_env_int_array("列表值")
			if Input.is_action_just_pressed("EMU_START"):
				var idxes = []
				for i in actorIds.size():
					if actorIds[i] < 0:
						continue
					idxes.append(i)
				SceneManager.lsc_menu_top.lsc.set_selected_by_array(idxes)
				return
			var option = wait_for_choose_item("")
			if option < 0:
				return
			var cityId = DataManager.get_env_int("值")
			var vstateId = DataManager.get_env_int("战争.结算方")
			var wv = wf.get_war_vstate(vstateId)
			var selectedId = actorIds[option]
			if selectedId >= 0:
				var actor = ActorHelper.actor(selectedId)
				if actor.get_loyalty() == 100 and cityId < 0:
					return
				SceneManager.lsc_menu_top.lsc.set_selected_change()
				return
			# 选择结束
			LoadControl.set_view_model(-1)
			var selected = SceneManager.lsc_menu_top.lsc.get_selected_list()
			if cityId >= 0:
				# 撤退到城池
				for idx in selected:
					var actorId = actorIds[idx]
					if wv.main_actorId == actorId:
						# 是主将，带资源走
						var targetCity = clCity.city(cityId)
						targetCity.add_gold(wv.money)
						targetCity.add_rice(wv.rice)
						wv.money = 0
						wv.rice = 0
					var wa = DataManager.get_war_actor(actorId)
					wa.retreat_to(cityId)
				# 军营武将去第一个选择的城市
				for campActorId in wv.camp_actors:
					clCity.move_to(campActorId, cityId)
				wv.camp_actors.clear()
				# 跟随武将去第一个选择的城市
				for followingActorId in wv.following_actors:
					clCity.move_to(followingActorId, cityId)
				wv.following_actors.clear()
				# 俘虏武将去第一个选择的城市
				for captureActorId in wv.capture_actors:
					clCity.move_to_ceil(captureActorId, cityId)
				wv.capture_actors.clear()
			else:
				# 下野
				var avaiableCityIds = wf.target_city().get_connected_city_ids()
				avaiableCityIds.append(wf.target_city().ID)
				for idx in selected:
					var actorId = actorIds[idx]
					if wv.main_actorId == actorId:
						wv.money = 0
						wv.rice = 0
					var wa = DataManager.get_war_actor(actorId)
					wa.actor().set_dislike_vstate_id(wv.vstateId)
					avaiableCityIds.shuffle()
					wa.banish_to(avaiableCityIds[0])
			FlowManager.add_flow("settle_2")
		1006:
			wait_for_confirmation("war_over_end")
		1010:
			var option = wait_for_view_item()
			if option < 0:
				return
			if Global.is_action_pressed_AX():
				match get_env_int_array("列表值")[option]:
					-1:
						DataManager.auto_save("endless")
						FlowManager.add_flow("war_over_end")
					-2:
						FlowManager.add_flow("endless_equip")
					-3:
						FlowManager.add_flow("endless_school")
				return
			if option != get_env_int("值"):
				set_env("值", option)
				FlowManager.add_flow("endless_settle_2")
	return

func settle_init():
	#界面展示
	var scene_war = SceneManager.current_scene()
	if not is_instance_valid(scene_war):
		return
	var war_communique = scene_war.war_communique
	war_communique.init_data()
	war_communique.show()
	return

#开始
func settle_start():
	settle_init()
	SoundManager.play_bgm("res://resource/sounds/bgm/War_End.ogg", true, true, true);
	SceneManager.show_confirm_dialog("战斗完成")
	LoadControl.set_view_model(1001)
	return

#检查是否存在需要撤退的武将
func settle_2():
	var wf = DataManager.get_current_war_fight()
	var vstateId = DataManager.get_env_int("战争.结算方")
	var wv = wf.get_war_vstate(vstateId)
	if wv.get_actors_count() == 0:
		LoadControl.set_view_model(-1)
		if wv.lost():
			# 已经没有需要处理的武将了，调用自动处理
			wv.settle_after_war()
		FlowManager.add_flow("war_over_next")
		return
	var p:Player = DataManager.players[FlowManager.controlNo]
	var actor = ActorHelper.actor(p.actorId)
	var msg = "{0}大人\n撤退到哪个城？".format([actor.get_name()])
	SceneManager.show_confirm_dialog(msg)
	LoadControl.set_view_model(1002)
	return

#选择撤退城池
func settle_3():
	var wf = DataManager.get_current_war_fight()
	var vstateId = DataManager.get_env_int("战争.结算方")
	var wv = wf.get_war_vstate(vstateId)
	SceneManager.hide_all_tool()
	var items = []
	var values = []
	for targetId in wv.get_all_retreat_city_ids():
		var targetCity = clCity.city(targetId)
		var fmt = "{0} {1}"
		if targetId == wf.from_city().ID:
			fmt = "{0} {1}#C32,32,212"
		items.append(fmt.format([targetCity.get_name(), targetCity.get_actors_count()]))
		values.append(targetId)
	# 无城可撤时，全员下野
	if values.empty():
		var lordWA = null
		for wa in wv.get_war_actors(false):
			if wa.actorId != wa.get_lord_id():
				wa.banish_to(wf.target_city().ID)
			else:
				lordWA = wa
		if lordWA != null:
			lordWA.actor_capture_to(wv.get_enemy_vstate().id, "结算")
			FlowManager.add_flow("settle_2")
			return
	#增加下野选项
	items.append("下野")
	values.append(-1)
	DataManager.set_env("列表值", values)
	SceneManager.lsc_menu.lsc.columns = 3
	SceneManager.lsc_menu.lsc.items = items
	SceneManager.lsc_menu.set_lsc(Vector2(-60, -40), Vector2(160, 40))
	SceneManager.lsc_menu.show_orderbook(false)
	SceneManager.lsc_menu.show_msg("")
	SceneManager.lsc_menu.lsc._set_data(30)
	SceneManager.lsc_menu.show()
	LoadControl.set_view_model(1003)
	return

#对话确认
func settle_4():
	var p:Player = DataManager.players[FlowManager.controlNo]
	var actor = ActorHelper.actor(p.actorId)
	var retreatCityId = DataManager.get_env_int("值")
	var msg = "大人\n请选择撤退之武将"
	if retreatCityId < 0:
		msg = "大人\n请选择流放下野之武将"
	msg = actor.get_name() + msg
	DataManager.set_env("对白", msg)
	DataManager.set_env("列表页码", 0)
	SceneManager.show_confirm_dialog(msg)
	LoadControl.set_view_model(1004)
	return

#选择武将
func settle_5():
	var wf = DataManager.get_current_war_fight()
	var vstateId = DataManager.get_env_int("战争.结算方")
	var wv = wf.get_war_vstate(vstateId)
	SceneManager.hide_all_tool()
	
	var page = DataManager.get_env_int("列表页码")
	var pageSize = 23
	var actorsCount = wv.get_actors_count()
	
	var items = []
	var values = []
	for wa in wv.get_war_actors(false):
		if items.size() >= pageSize:
			break
		items.append(wa.get_name())
		values.append(wa.actorId)
	items.append("结束")
	values.append(-1)
	DataManager.set_env("列表值", values)
	SceneManager.lsc_menu_top.set_lsc(Vector2(20, 0), Vector2(160, 42))
	SceneManager.lsc_menu_top.lsc.columns = 3
	SceneManager.lsc_menu_top.lsc.items = items
	SceneManager.lsc_menu_top.lsc._set_data()
	SceneManager.show_unconfirm_dialog(DataManager.get_env_str("对白"))
	SceneManager.dialog_msg_complete(true)
	SceneManager.lsc_menu_top.show()
	LoadControl.set_view_model(1005)
	return

#选择武将
func endless_settle_2():
	LoadControl.set_view_model(-1)
	var items = []
	var values = []
	for actorId in EndlessGame.player_actors:
		var actorName = ActorHelper.actor(actorId).get_name()
		items.append(actorName)
		values.append(actorId)

	if EndlessGame.pass_no % 5 == 4:
		items.append("装备库#C32,32,212")
		values.append(-2)
		items.append("学问馆#C32,32,212")
		values.append(-3)
	items.append("结束#C212,32,32")
	values.append(-1)

	SceneManager.hide_all_tool()
	DataManager.set_env("列表值", values)
	SceneManager.lsc_menu_top.set_lsc(Vector2(20, 0), Vector2(160, 42))
	SceneManager.lsc_menu_top.lsc.columns = 3
	SceneManager.lsc_menu_top.lsc.items = items
	SceneManager.lsc_menu_top.lsc._set_data()
	SceneManager.lsc_menu_top.lsc.cursor_index = DataManager.get_env_int("值")
	var msg = "无尽成长一览\n[{0}] 第{1}关".format([
		StaticManager.DIFFICULTY_NAMES[DataManager.diffculities],
		EndlessGame.pass_no + 1, 
	]);
	var actorId = values[SceneManager.lsc_menu_top.lsc.cursor_index]
	if actorId >= 0:
		SceneManager.show_actor_info(actorId)
	SceneManager.lsc_menu_top.status.rect_position = Vector2(380, 290)
	SceneManager.lsc_menu_top.status.rect_size = Vector2(180, 80)
	SceneManager.lsc_menu_top.status.bbcode_text = msg
	SceneManager.lsc_menu_top.status.show()
	SceneManager.lsc_menu_top.show()
	LoadControl.set_view_model(1010)
	return

# 无尽模式装备库
func endless_equip():
	LoadControl.load_script("affiars/warehouse_equip.gd")
	FlowManager.add_flow("wh_equip_init")
	LoadControl.set_view_model(1020)
	return

# 无尽模式学问馆
func endless_school():
	LoadControl.set_view_model(1030)
	LoadControl.load_script("affiars/fair_school.gd")
	FlowManager.add_flow("school_start")
	return

func war_equip_done():
	FlowManager.add_flow("endless_settle_2")
	return

func war_school_done():
	FlowManager.add_flow("endless_settle_2")
	return
