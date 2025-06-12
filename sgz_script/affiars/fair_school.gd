extends "affairs_base.gd"

var prev_view_model_name = ""

#学问馆
func _init()->void:
	prev_view_model_name = LoadControl.view_model_name
	LoadControl.view_model_name = "内政-玩家-步骤"
	FlowManager.bind_signal_method("school_start", self)
	FlowManager.bind_signal_method("school_2", self)
	FlowManager.bind_signal_method("school_3", self)
	FlowManager.bind_signal_method("school_done", self)
	FlowManager.bind_signal_method("school_cancel", self)
	
	FlowManager.clear_pre_history.append("school_start")
	FlowManager.clear_pre_history.append("school_2")
	FlowManager.clear_pre_history.append("school_3")
	return

#按键操控
func _input_key(delta: float):
	var scene_affiars:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	match LoadControl.get_view_model():
		421:#选人
			if not wait_for_choose_actor("school_cancel"):
				return
			var actorId = SceneManager.actorlist.get_select_actor();
			DataManager.player_choose_actor = actorId;
			FlowManager.add_flow("school_2");
		422:#提升属性
			SceneManager.actor_addpoint.hide_levelup_all()
			if Input.is_action_pressed("EMU_SELECT"):
				SceneManager.actor_addpoint.show_levelup_all()
			if(Input.is_action_just_pressed("ANALOG_UP")):
				SceneManager.actor_addpoint.move_up();
			if(Input.is_action_just_pressed("ANALOG_DOWN")):
				SceneManager.actor_addpoint.move_down();
			if(Input.is_action_just_pressed("ANALOG_LEFT")):
				SceneManager.actor_addpoint.decrease();
			if(Input.is_action_just_pressed("ANALOG_RIGHT")):
				SceneManager.actor_addpoint.increase();
			if DataManager.is_developer() and Input.is_action_just_pressed("EMU_START"):
				SceneManager.actor_addpoint.level_reset()
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				FlowManager.add_flow("school_3");
			if(Global.is_action_pressed_BY()):
				if(!SceneManager.dialog_msg_complete(false)):
					return;
				var nextFlow = DataManager.get_env_str("进修.返回")
				if nextFlow == "":
					nextFlow = "school_start"
				else:
					DataManager.unset_env("进修.返回")
				FlowManager.add_flow(nextFlow)
		423:
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
				if SceneManager.actor_dialog.lsc.cursor_index == 0:
					SceneManager.actor_addpoint.into_actor()
				var nextFlow = DataManager.get_env_str("进修.返回")
				if nextFlow == "":
					nextFlow = "school_done"
				else:
					DataManager.unset_env("进修.返回")
				FlowManager.add_flow(nextFlow)
			if(Global.is_action_pressed_BY()):
				if(!SceneManager.dialog_msg_complete(false)):
					return;
				FlowManager.add_flow("school_2");
		429:
			if not Global.is_action_pressed_AX():
				return
			if not SceneManager.dialog_msg_complete(true):
				return
			LoadControl.set_view_model(-1)
			var nextFlow = DataManager.get_env_str("进修.返回")
			if nextFlow == "":
				nextFlow = "school_done"
			DataManager.unset_env("进修.返回")
			FlowManager.add_flow(nextFlow)
	return

#选人
func school_start():
	var actorIds = []
	var sceneId = DataManager.get_current_scene_id()
	if sceneId == 20000 and DataManager.endless_model:
		actorIds.append_array(EndlessGame.player_actors)
	else:
		SceneManager.current_scene().cursor.hide()
		var cityId = DataManager.player_choose_city
		DataManager.twinkle_citys = [cityId]
		var city = clCity.city(cityId)
		actorIds.append_array(city.get_actor_ids())
	var msg = "哪位要进修？请指定"
	SceneManager.show_actorlist_learning(actorIds, false, msg)
	var lastSelectedActorId = DataManager.get_env_int("内政.学习武将")
	var lastSelectedIdx = actorIds.find(lastSelectedActorId)
	if lastSelectedIdx >= 0:
		SceneManager.actorlist.move_to(lastSelectedIdx)
	LoadControl.set_view_model(421)
	return

#选择升什么
func school_2():
	var actorId = DataManager.player_choose_actor
	if DataManager.get_game_setting("武将成长") in ["禁读书", "就不加"]:
		SceneManager.show_confirm_dialog("已设定禁读书", actorId)
		LoadControl.set_view_model(429)
		return
	var cityId = DataManager.player_choose_city
	var sceneId = DataManager.get_current_scene_id()
	if sceneId == 20000:
		var wf = DataManager.get_current_war_fight()
		cityId = wf.target_city().ID
	DataManager.set_env("内政.学习武将", actorId)
	SceneManager.hide_all_tool()
	SceneManager.show_unconfirm_dialog("提升哪种属性？\n← →控制属性增减\n按住「选择」键查看成长信息", actorId)
	var expRate = SkillRangeBuff.min_for_city("学习经验折扣", cityId)
	if expRate <= 0:
		expRate = 1.0
	# 暂时固定在这里，并用 relation 实现
	var SPECIFIED = {
		"同槽": "父亲",
	}
	for srb in SkillRangeBuff.find_for_city("定向学习经验折扣", cityId):
		if srb.effectTagVal <= 0 or srb.effectTagVal > expRate:
			continue
		if not srb.skillName in SPECIFIED:
			continue
		var relation = SPECIFIED[srb.skillName]
		if DataManager.get_actor_honored_title(srb.actorId, actorId) == relation:
			expRate = srb.effectTagVal
	SceneManager.actor_addpoint.set_actor(actorId, expRate)
	SceneManager.actor_addpoint.show()
	LoadControl.set_view_model(422)
	return

func school_3():
	LoadControl.set_view_model(423);
	SceneManager.hide_all_tool();
	var actorId = int(DataManager.player_choose_actor);
	SceneManager.show_yn_dialog("是否保存更改？",actorId);
	SceneManager.actor_addpoint.show();
	return

func school_done():
	LoadControl.view_model_name = prev_view_model_name
	var sceneId = DataManager.get_current_scene_id()
	if sceneId == 20000 and DataManager.endless_model:
		LoadControl.end_script()
		LoadControl.load_script("war/player_over_settle.gd")
		FlowManager.add_flow("war_school_done")
		return
	FlowManager.add_flow("school_start")
	return

func school_cancel():
	DataManager.unset_env("内政.学习武将")
	LoadControl.view_model_name = prev_view_model_name
	var sceneId = DataManager.get_current_scene_id()
	if sceneId == 20000 and DataManager.endless_model:
		LoadControl.end_script()
		LoadControl.load_script("war/player_over_settle.gd")
		FlowManager.add_flow("war_school_done")
		return
	FlowManager.add_flow("enter_fair_menu")
	return
