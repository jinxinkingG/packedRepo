extends Resource

#大限死亡率
const DEATH_RATES = [2.5, 5, 10, 18.5, 40, 80, 100]

#武将大限/战后死亡&君主继位
func _init() -> void:
	LoadControl.view_model_name = "内政-君主灭亡-步骤";
	FlowManager.bind_import_flow("check_actor_dead_start", self)
	FlowManager.bind_import_flow("check_actor_dead_next", self)
	FlowManager.bind_import_flow("check_actor_dead_end", self)
	FlowManager.bind_import_flow("dead_player_1", self)
	FlowManager.bind_import_flow("dead_player_2", self)
	FlowManager.bind_import_flow("dead_player_3", self)
	FlowManager.bind_import_flow("dead_player_4", self)
	FlowManager.bind_import_flow("dead_player_5", self)
	FlowManager.bind_import_flow("dead_player_end", self)

	FlowManager.bind_import_flow("dead_AI_2", self)
	FlowManager.bind_import_flow("AI_perished", self)
	return
	
#按键操控
func _input_key(delta: float):
	var scene_affiars:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	if not DataManager.common_variable.has("值"):
		return
	var vstateId = DataManager.get_env_int("值")
	var vs = clVState.vstate(vstateId)
	match view_model:
		1:#确认
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				if DataManager.get_env_int("武将") == vs.get_lord_id():
					#君主死亡时
					var cities = clCity.all_cities([vstateId])
					if cities.size() == 0:
						FlowManager.add_flow("dead_player_end")
					elif cities.size() == 1:
						DataManager.player_choose_city = cities[0].ID
						FlowManager.add_flow("dead_player_2");
					else:
						var capital = clCity.get_capital_city(vs.id)
						if capital == null:
							capital = cities[0]
						DataManager.player_choose_city = capital.ID
						FlowManager.add_flow("dead_player_2");
				else:
					#非君主死亡时
					FlowManager.add_flow("check_actor_dead_start");
		2:#选择继承人所在城池
			if(Input.is_action_pressed("ANALOG_UP")):
				scene_affiars.cursor_move_up(delta);
			if(Input.is_action_pressed("ANALOG_DOWN")):
				scene_affiars.cursor_move_down(delta);
			if(Input.is_action_pressed("ANALOG_LEFT")):
				scene_affiars.cursor_move_left(delta);
			if(Input.is_action_pressed("ANALOG_RIGHT")):
				scene_affiars.cursor_move_right(delta);
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				var cityId = scene_affiars.get_curosr_point_city();
				if(cityId<0):
					SceneManager.show_unconfirm_dialog("此处并没有城");
					return;
				var city = clCity.city(cityId)
				if city.get_vstate_id() != vstateId:
					SceneManager.show_unconfirm_dialog("此乃敌方城池");
					return;
				var player:Player = DataManager.players[FlowManager.controlNo];
				if(!cityId in player.get_control_citys()):
					SceneManager.show_unconfirm_dialog("没有权限控制该城");
					return;
				DataManager.player_choose_city = cityId;
				FlowManager.add_flow("dead_player_3");
		3:#选择武将
			if(Input.is_action_just_pressed("ANALOG_UP")):
				SceneManager.actorlist.move_up();
			if(Input.is_action_just_pressed("ANALOG_DOWN")):
				SceneManager.actorlist.move_down();
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.actorlist.is_msg_complete()):
					SceneManager.actorlist.show_all_msg();
					return;
				DataManager.common_variable["武将"] = int(SceneManager.actorlist.get_select_actor());
				FlowManager.add_flow("dead_player_4");
			if(Global.is_action_pressed_BY()):
				if(!SceneManager.actorlist.is_msg_complete()):
					return;
				FlowManager.add_flow("dead_player_2");
		4:#确认君主
			if Input.is_action_just_pressed("ANALOG_LEFT"):
				SceneManager.actor_dialog.move_left()
			if Input.is_action_just_pressed("ANALOG_RIGHT"):
				SceneManager.actor_dialog.move_right()
			if Input.is_action_just_pressed("ANALOG_UP"):
				SceneManager.actor_dialog.move_up()
			if Input.is_action_just_pressed("ANALOG_DOWN"):
				SceneManager.actor_dialog.move_down()
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				match SceneManager.actor_dialog.lsc.cursor_index:
					0:
						FlowManager.add_flow("dead_player_5");
					1:
						FlowManager.add_flow("dead_player_2");
		5:#确认结果
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				FlowManager.add_flow("check_actor_dead_start")
		1001:
			Global.wait_for_confirmation("dead_AI_2", "", delta)
		1002:
			Global.wait_for_confirmation("check_actor_dead_start", "", delta)
	return

func check_actor_dead_start():
	LoadControl.set_view_model(-1)
	SceneManager.cleanup_animations()

	DataManager.show_orderbook = false
	SceneManager.current_scene().show_city_line(false)
	SceneManager.current_scene().cursor.hide()

	var checked = DataManager.get_env_int_array("大限检查")
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no]
	DataManager.set_env("值", vstateId)
	for city in clCity.all_cities([vstateId]):
		if city.get_actors_count() == 0:
			city.change_vstate(-1)
			continue
		for actorId in city.get_actor_ids():
			#本月已经检查过的武将不再检查
			if actorId in checked:
				continue
			checked.append(actorId)
			DataManager.set_env("大限检查", checked)
			var actor = ActorHelper.actor(actorId)
			var lifeLeft = DataManager.year - actor.get_life_limit()
			if lifeLeft < 0:
				continue
			var deathRate:int = DEATH_RATES[min(lifeLeft, DEATH_RATES.size()-1)]
			# 如果是出仕状态，概率死亡
			# 否则直接死亡
			if not Global.get_rate_result(deathRate) and actor.is_status_officed():
				continue
			var lordId = city.get_lord_id()
			actor.set_status_dead()
			clCity.move_out(actorId)
			if city.get_actors_count() == 0:
				city.change_vstate(-1)
			
			DataManager.set_env("武将", actor.actorId)
			var actorControlNo = DataManager.get_actor_controlNo(actor.actorId)
			if actorControlNo < 0:
				if lordId >= 0:
					actorControlNo = DataManager.get_actor_controlNo(lordId)
			# 玩家武将死亡
			if actorControlNo >= 0:
				FlowManager.set_current_control_playerNo(actorControlNo)
				FlowManager.add_flow("dead_player_1")
				return

	for vs in clVState.all_vstates():
		if vs.is_perished():
			continue
		var lord = ActorHelper.actor(vs.get_lord_id())
		if lord.is_status_officed() and lord.get_loyalty() == 100:
			#非出仕就走继位判断
			continue
		DataManager.set_env("值", vs.id)
		DataManager.set_env("武将", lord.actorId)
		FlowManager.add_flow("check_actor_dead_next")
		return
	DataManager.game_trace("CHECK_ACTOR_DEAD")
	FlowManager.add_flow("check_actor_dead_end")
	return

func check_actor_dead_next():
	var lordId = DataManager.get_env_int("武将")
	var lordControlNo = DataManager.get_actor_controlNo(lordId)
	if lordControlNo < 0:
		_dead_AI_1()
	else:
		SceneManager.hide_all_tool()
		FlowManager.set_current_control_playerNo(lordControlNo)
		FlowManager.add_flow("dead_player_1")
	return

func _dead_AI_1():
	LoadControl.set_view_model(-1)
	var vstateId = DataManager.get_env_int("值")
	var actorId = DataManager.get_env_int("武将")
	var vs = clVState.vstate(vstateId)
	var actor = ActorHelper.actor(actorId)
	var msg = "{0}死亡"
	if not actor.is_status_dead():
		msg = "{0}军兵败如山倒"
	msg = msg.format([actor.get_name()])

	SceneManager.play_affiars_animation("Player_Defeat", "", false, msg)
	DataManager.twinkle_citys = clCity.all_city_ids([vs.id])
	LoadControl.set_view_model(1001)
	return
	
func dead_AI_2():
	SceneManager.cleanup_animations()
	var vstateId = DataManager.get_env_int("值")
	var lordId = DataManager.get_env_int("武将")
	var vs = clVState.vstate(vstateId)
	if vs.is_perished():
		FlowManager.add_flow("check_actor_dead_start")
		return

	# 首先处理前任君主忠诚度
	var prevKing = ActorHelper.actor(vs.get_lord_id())
	prevKing.set_loyalty(min(99, prevKing.get_loyalty()))
	var lord = ActorHelper.actor(lordId)
	var newLordId = -1
	var max_score = -20000;
	var cityId = -1;
	var lord_array = vs.get_inheritage_candidates()
	lord_array.invert();#继承人逆序排列
	
	#遍历所有己方城池的武将
	for city in clCity.all_cities([vstateId]):
		for actorId in city.get_actor_ids():
			var actor = ActorHelper.actor(actorId)
			#默认按德的差值作为评分，差值越小，分越高
			var score = -abs(lord.get_loyalty() - actor.get_loyalty())
			
			#如果是继承人，评分为正数
			if actorId in PoolIntArray(lord_array):
				#检索继承人
				var index = PoolIntArray(lord_array).find(actorId)
				score = index*1000;
			if score > max_score:
				#替换最高分
				max_score = score;
				newLordId = actorId;
				cityId = city.ID

	var msg = ""
	if newLordId < 0:
		if DataManager.vstates_sort[DataManager.vstate_no] == vs.id:
			DataManager.orderbook = 0
		vs.set_perished()
		FlowManager.add_flow("AI_perished")
		return

	# 更换君主，可能触发势力 id 变化
	var newVstateId = DataManager.lord_change(vs.id, newLordId)
	var newLord = ActorHelper.actor(newLordId)
	newLord.set_loyalty(100)
	clCity.move_to(newLordId, cityId)
	SceneManager.cityId = cityId
	msg = "{0}继承君主之位".format([newLord.get_name()])

	# TODO, 替换动画
	SceneManager.play_affiars_animation("Player_Defeat", "", false, msg)
	DataManager.twinkle_citys = clCity.all_city_ids([vs.id])
	LoadControl.set_view_model(1002)
	return

func AI_perished() -> void:
	var vstateId = DataManager.get_env_int("值")
	var vs = clVState.vstate(vstateId)
	var lordId = DataManager.get_env_int("武将")
	var lord = ActorHelper.actor(lordId)
	var msg = "{0}势力灭亡".format([lord.get_name()])

	DataManager.set_env("内政.灭亡势力", vs.id)
	for v in clVState.all_vstates(true):
		SkillHelper.auto_trigger_skill(v.get_lord_id(), 10023)

	SceneManager.play_affiars_animation("Player_Defeat", "", false, msg)
	DataManager.twinkle_citys = []
	LoadControl.set_view_model(1002)
	return

func check_actor_dead_end():
	LoadControl.set_view_model(-1)
	LoadControl.end_script()
	FlowManager.add_flow("turn_control_start")
	return

#玩家君主死亡，强提示
func dead_player_1():
	var lordId = DataManager.get_env_int("武将")
	var actor = ActorHelper.actor(lordId)
	var msg = "{0}已不知所踪"
	if actor.is_status_dead():
		msg = "{0}死亡"
	elif actor.is_status_captured():
		msg = "{0}已被俘虏"
	SceneManager.show_confirm_dialog(msg.format([actor.get_name()]))
	LoadControl.set_view_model(1)
	return

#指定继承人所在城池
func dead_player_2():
	DataManager.twinkle_citys.clear()
	var scene_affiars:Control = SceneManager.current_scene()
	scene_affiars.show_city_line(false)
	scene_affiars.cursor.show()
	
	scene_affiars.set_city_cursor_position(DataManager.player_choose_city)
	SceneManager.show_unconfirm_dialog("请指定继承人\n所在城池")
	LoadControl.set_view_model(2)
	return

#指定继承人
func dead_player_3():
	var city = clCity.city(DataManager.player_choose_city)
	SceneManager.show_actorlist_develop(city.get_actor_ids(),false,"让何人继承君主之位?");
	LoadControl.set_view_model(3)
	return

func dead_player_4():
	var newLordId = DataManager.get_env_int("武将")
	var scene_affiars:Control = SceneManager.current_scene();
	scene_affiars.cursor.hide();
	var actor = ActorHelper.actor(newLordId)
	SceneManager.show_yn_dialog("{0}可否？".format([actor.get_name()]))
	LoadControl.set_view_model(4)
	return

func dead_player_5():
	var vstateId = DataManager.get_env_int("值")
	var newLordId = DataManager.get_env_int("武将")
	if SkillHelper.auto_trigger_skill(newLordId, 10020, "dead_player_5"):
		return
	var vs = clVState.vstate(vstateId)
	var oldLordId = vs.get_lord_id()
	var newLord = ActorHelper.actor(newLordId)
	var player:Player = DataManager.players[FlowManager.controlNo];
	var city = clCity.city(DataManager.player_choose_city)
	
	var newVstateId = DataManager.lord_change(vstateId, newLord.actorId)
	newLord.set_loyalty(100)
	clCity.move_to(newLord.actorId, city.ID)
	vs.set_lord(newLord.actorId)
	if DataManager.game_mode == 0 && player.actorId == oldLordId:
		player.actorId = newLord.actorId
	SceneManager.show_confirm_dialog("{0}继承君主之位".format([newLord.get_name()]))
	LoadControl.set_view_model(5)
	return

#无城可选
func dead_player_end():
	var vstateId = DataManager.get_env_int("值")
	var vs = clVState.vstate(vstateId)
	vs.set_perished()
	var player:Player = DataManager.players[FlowManager.controlNo];
	player.actorId = -2;
	SceneManager.show_confirm_dialog("{0}势力灭亡".format([vs.get_dynasty_title_or_lord_name()]))
	LoadControl.set_view_model(1002)
	return
