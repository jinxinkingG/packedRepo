extends Resource

#手动撤退
func _init() -> void:
	LoadControl.view_model_name = "战争-玩家-步骤";
	
	FlowManager.bind_signal_method("retreat_start",self,"retreat_start");
	FlowManager.bind_signal_method("retreat_city_choose",self,"retreat_city_choose");
	FlowManager.bind_signal_method("retreat_to_city_1",self,"retreat_to_city_1");
	FlowManager.bind_signal_method("retreat_to_city_2",self,"retreat_to_city_2");
	FlowManager.bind_signal_method("banish_1",self,"banish_1");
	FlowManager.bind_signal_method("banish_2",self,"banish_2");
	FlowManager.bind_signal_method("banish_3",self,"banish_3");
	pass


#按键操控
func _input_key(delta: float):
	var wf = DataManager.get_current_war_fight()
	if wf == null:
		return
	var scene_war:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	match view_model:
		141:#确认对话
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				FlowManager.add_flow("retreat_city_choose");
			if(Global.is_action_pressed_BY()):
				if(!SceneManager.dialog_msg_complete(false)):
					return;
				FlowManager.add_flow("player_ready");
		142:#选择城池
			if(Input.is_action_just_pressed("ANALOG_UP")):
				bottom.lsc.move_up();
			if(Input.is_action_just_pressed("ANALOG_DOWN")):
				bottom.lsc.move_down();
			if(Input.is_action_just_pressed("ANALOG_LEFT")):
				bottom.lsc.move_left();
			if(Input.is_action_just_pressed("ANALOG_RIGHT")):
				bottom.lsc.move_right();
			if(Global.is_action_pressed_AX()):
				if(!bottom.is_msg_complete()):
					bottom.show_all_msg();
					return;
				var wv = wf.current_war_vstate()
				var value_array = DataManager.get_env_int_array("列表值")
				var choose_value = int(value_array[bottom.lsc.cursor_index]);
				DataManager.set_env("值", choose_value)
				match choose_value:
					-1:#下野
						if wv.get_lord_id() == DataManager.player_choose_actor:
							LoadControl._error("不可流放君主");
							return;
						FlowManager.add_flow("banish_1");
					_:#撤退到城池
						FlowManager.add_flow("retreat_to_city_1");
			if(Global.is_action_pressed_BY()):
				if(!bottom.is_msg_complete()):
					return;
				FlowManager.add_flow("player_ready");
		143:#撤退前最后1次确认
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				FlowManager.add_flow("retreat_to_city_2");
			if(Global.is_action_pressed_BY()):
				if(!SceneManager.dialog_msg_complete(false)):
					return;
				FlowManager.add_flow("player_ready");
		144:#撤退完成
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				var wv = wf.current_war_vstate()
				if DataManager.player_choose_actor == wv.main_actorId:
					if wv.is_reinforcement():
						# 如果是援军主将，视为失败结算
						wv.lose_reason = War_Vstate.Lose_ReasonEnum.NoMind;#不提示
						wv.settle_after_war(true)
						# 并结束回合
						FlowManager.add_flow("player_end")
					else:
						# 主军势，如果撤退了主将，则直接失败
						wv.lose_reason = War_Vstate.Lose_ReasonEnum.NoMind;#不提示
						FlowManager.add_flow("war_over_start")
					return
				FlowManager.add_flow("player_ready");
		151:#确认流放
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
						FlowManager.add_flow("banish_2");
					1:
						FlowManager.add_flow("player_ready");
			if(Global.is_action_pressed_BY()):
				if(!SceneManager.dialog_msg_complete(false)):
					return;
				FlowManager.add_flow("player_ready");
		152:#流放完成
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				FlowManager.add_flow("banish_3");
		153:#
			Global.wait_for_confirmation("player_ready")
	return

#对话确认1
func retreat_start():
	var wf = DataManager.get_current_war_fight()
	var wv = wf.current_war_vstate()
	var msg = "{0}大人\n撤退到哪个城？".format([
		wv.get_leader().get_name()
	])
	SceneManager.show_confirm_dialog(msg, DataManager.player_choose_actor)
	LoadControl.set_view_model(141)
	return

#选择撤退的城
func retreat_city_choose():
	var wf = DataManager.get_current_war_fight()
	var wv = wf.current_war_vstate()
	var warCity = wf.target_city()
	var war_map = SceneManager.current_scene().war_map
	war_map.cursor.hide();
	war_map.update_ap();#立刻更新机动力显示
	war_map.next_shrink_actors = [DataManager.player_choose_actor]
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
	#非君主增加下野选项
	items.append("下野")
	values.append(-1)
	
	if values.empty():
		#当没得选时，直接返回
		LoadControl._error("无路可退",DataManager.player_choose_actor)
		return
	DataManager.common_variable["列表值"] = values
	SceneManager.lsc_menu.lsc.columns = 3;
	SceneManager.lsc_menu.lsc.items = items
	SceneManager.lsc_menu.set_actor_lsc(DataManager.player_choose_actor, Vector2(0, -40), Vector2(140, 40))
	SceneManager.lsc_menu.show_msg("")
	SceneManager.lsc_menu.lsc._set_data(30)
	SceneManager.lsc_menu.show()
	LoadControl.set_view_model(142)
	return

#撤退：对话确认2
func retreat_to_city_1():
	var wf = DataManager.get_current_war_fight()
	var wv = wf.current_war_vstate()
	var msg = "既然如此\n便先行撤退"
	if DataManager.player_choose_actor == wv.main_actorId:
		msg = "全军撤退，重整旗鼓"
	SceneManager.show_confirm_dialog(msg, DataManager.player_choose_actor)
	LoadControl.set_view_model(143)
	return

#撤退完成确认
func retreat_to_city_2():
	var wf = DataManager.get_current_war_fight()
	var wv = wf.current_war_vstate()
	var cityId = DataManager.get_env_int("值")
	var city = clCity.city(cityId)
	var wa = DataManager.get_war_actor(DataManager.player_choose_actor)
	wa.retreat_to(cityId)
	
	if wv.main_actorId == wa.actorId:
		# 军营武将
		for campActorId in wv.camp_actors:
			clCity.move_to(campActorId, cityId)
		wv.camp_actors.clear()
		# 跟随武将
		for followingActorId in wv.following_actors:
			clCity.move_to(followingActorId, cityId)
		wv.following_actors.clear()
		# 俘虏武将
		for captureActorId in wv.capture_actors:
			clCity.move_to_ceil(captureActorId, cityId)
		wv.capture_actors.clear()

	var msg = "已安然撤回{0}".format([
		city.get_full_name(),
	])
	SceneManager.show_confirm_dialog(msg)
	FlowManager.add_flow("draw_actors")
	LoadControl.set_view_model(144)
	return

#下野
func banish_1():
	var actor = ActorHelper.actor(DataManager.player_choose_actor)
	var msg = "确定要将{0}流放下野吗？".format([actor.get_name()])
	SceneManager.show_yn_dialog(msg)
	LoadControl.set_view_model(151)
	return

#下野完成确认
func banish_2():
	var wa = DataManager.get_war_actor(DataManager.player_choose_actor)
	var wf = DataManager.get_current_war_fight()
	var wv = wf.current_war_vstate()
	var warCity = wf.target_city()
	var availableCityIds = warCity.get_connected_city_ids()
	availableCityIds.append(warCity.ID)
	availableCityIds.erase(wv.from_cityId)
	availableCityIds.shuffle()
	wa.actor().set_dislike_vstate_id(wa.vstate().id)
	wa.banish_to(availableCityIds[0])
	SceneManager.show_confirm_dialog("为何如此对我……", wa.actorId, 3)
	LoadControl.set_view_model(152)
	return

func banish_3():
	LoadControl.set_view_model(153);
	var actor = ActorHelper.actor(DataManager.player_choose_actor)	
	SceneManager.show_confirm_dialog("{0}被流放下野了".format([actor.get_name()]));
	FlowManager.add_flow("draw_actors");
