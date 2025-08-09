extends "affairs_base.gd"

#监狱
func _init() -> void:
	LoadControl.view_model_name = "内政-玩家-步骤";

	FlowManager.bind_signal_method("ceil_menu", self)
	FlowManager.bind_signal_method("ceil_choose_actors", self)
	FlowManager.bind_signal_method("ceil_self_actors", self)
	FlowManager.bind_signal_method("ceil_confirmed", self)
	FlowManager.bind_signal_method("ceil_animation", self)
	FlowManager.bind_signal_method("ceil_result", self)
	FlowManager.bind_signal_method("ceil_trans_to_other_city", self)
	return

#按键操控
func _input_key(delta: float):
	var scene_affiars:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	match view_model:
		250:#选择执行的操作
			if not wait_for_options([], "enter_barrack_menu", true):
				return
			var cmds = DataManager.get_env_array("列表值")
			#招降/流放/转移/斩首/情报
			var cmd = cmds[SceneManager.lsc_menu.lsc.cursor_index]
			DataManager.set_env("值", cmd)
			FlowManager.add_flow("ceil_choose_actors")
		251:#选择单个囚犯，目前只有招降
			if not wait_for_choose_actor("ceil_menu"):
				return
			var aindex = SceneManager.actorlist.get_select_actor();
			DataManager.set_env("内政.监狱武将", [aindex])
			FlowManager.add_flow("ceil_self_actors");
		252:#派谁去招降
			if not wait_for_choose_actor("ceil_choose_actors"):
				return
			DataManager.set_env("武将", SceneManager.actorlist.get_select_actor())
			FlowManager.add_flow("ceil_confirmed");
		254:#监狱情报
			if Input.is_action_just_pressed("ANALOG_UP"):
				SceneManager.actor_info.prev_actor()
			if Input.is_action_just_pressed("ANALOG_DOWN"):
				SceneManager.actor_info.next_actor()
			if Global.is_action_pressed_BY():
				FlowManager.add_flow("ceil_menu")
				return
		255:
			wait_for_confirmation("ceil_result")
		256:#最后确认
			wait_for_confirmation()
		257:#转移城池
			#移动流程：选择城市
			var fromCity = clCity.city(DataManager.player_choose_city)
			var connectedCities = fromCity.get_connected_city_ids([fromCity.get_vstate_id()])
			var cityId = wait_for_choose_city(delta, "ceil_menu", connectedCities)
			if cityId < 0:
				return
			# 判断相连和归属
			if not cityId in connectedCities:
				SceneManager.show_unconfirm_dialog("无法转移至该城")
				return
			DataManager.set_env("目标城", cityId)
			FlowManager.add_flow("ceil_confirmed")
		261:#选择多个囚犯
			if not wait_for_choose_actor("ceil_menu", false, true):
				return
			if Input.is_action_just_pressed("EMU_START"):
				for id in SceneManager.actorlist.actorId_list:
					if id == -1 or SceneManager.actorlist.is_actor_picked(id):
						continue
					SceneManager.actorlist.set_actor_picked(id, 999)
				return
			var aindex = SceneManager.actorlist.get_select_actor()
			var actors:Array = SceneManager.actorlist.get_picked_actors()
			if aindex == -1:
				if actors.empty():
					FlowManager.add_flow("ceil_menu")
					return
				DataManager.set_env("内政.监狱武将", actors)
				match DataManager.get_env_str("值"):
					"转移":
						FlowManager.add_flow("ceil_trans_to_other_city")
					_:
						FlowManager.add_flow("ceil_confirmed")
			else:
				SceneManager.actorlist.set_actor_picked(aindex, 999);
	return

#查看监狱哪位武将
func ceil_choose_actors() -> void:
	var city = clCity.city(DataManager.player_choose_city)
	var ceilActors = city.get_ceil_actor_ids()
	#招降/流放/转移/斩首/情报/释放
	var cmd = DataManager.get_env_str("值")
	if cmd == "情报":
		SceneManager.show_actor_info_list(ceilActors)
		LoadControl.set_view_model(254)
		return
	var batch = false
	var notice = cmd + "哪位囚犯?"
	if cmd == "招降":
		LoadControl.set_view_model(251)
	else:
		batch = true
		notice = cmd + "哪些囚犯? (开始键全选)"
		LoadControl.set_view_model(261)
	
	var props = ["忠", "武", "知", "政", "德", "等级"]
	SceneManager.show_actorlist(ceilActors,batch,notice,false,props)
	return

func ceil_menu():
	var city = clCity.city(DataManager.player_choose_city)
	var ceilActors = city.get_ceil_actor_ids()
	if ceilActors.empty():
		LoadControl._affiars_error("现如今城内并无关押人员")
		return

	DataManager.set_env("武将", city.get_actor_ids()[0])
	
	var scene_affiars:Control = SceneManager.current_scene();
	scene_affiars.cursor.hide();
	DataManager.twinkle_citys = [city.ID];
	SceneManager.hide_all_tool();
	var cmds = ["招降","流放","转移","斩首","情报","释放"]
	SceneManager.bind_bottom_menu("如何处置囚犯?", cmds, 2)
	DataManager.cityInfo_type = 2
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(250)
	return

#派遣哪位武将招降
func ceil_self_actors():
	var city = clCity.city(DataManager.player_choose_city)
	SceneManager.show_actorlist_develop(city.get_actor_ids(),false,"何人前往招降?");
	LoadControl.set_view_model(252)
	return

#执行命令
func ceil_confirmed():
	var vstateId = int(DataManager.vstates_sort[DataManager.vstate_no])
	var cityId = DataManager.player_choose_city
	var actorId = DataManager.get_env_int("武将")
	var targetActorIds = DataManager.get_env_int_array("内政.监狱武将")
	var action = DataManager.get_env_str("值")

	DataManager.set_env("结果", [])
	DataManager.set_env("对话", "")
	DataManager.set_env("提示", "")
	DataManager.set_env("动画", "")

	match action:
		"招降":
			_ceil_persuade(vstateId, cityId, actorId, targetActorIds)
		"流放":
			_ceil_exile(vstateId, cityId, targetActorIds)
		"斩首":
			_ceil_execute(vstateId, cityId, targetActorIds)
		"转移":
			var targetCityId = DataManager.get_env_int("目标城")
			_ceil_transfer(vstateId, cityId, targetCityId, targetActorIds)
		"释放":
			_ceil_release(vstateId, cityId, targetActorIds)
	FlowManager.add_flow("ceil_animation")
	return

func ceil_animation():
	var actorId = DataManager.get_env_int("武将")
	var animation = DataManager.get_env_str("动画")
	var notice = DataManager.get_env_str("提示")
	if animation == "":
		FlowManager.add_flow("ceil_result")
		return
	SceneManager.hide_all_tool()
	SceneManager.play_affiars_animation(
		animation, "", false,
		notice, actorId)
	LoadControl.set_view_model(255)
	return

func ceil_result():
	SceneManager.cleanup_animations()
	var result = DataManager.get_env_int_array("结果")
	var actorId = DataManager.get_env_int("武将")
	var mood = 2
	#招降/流放/斩首
	var action = DataManager.get_env_str("值")
	match action:
		"招降":
			if 1 in result:
				mood = 1
			else:
				mood = 3
	var msg = DataManager.get_env_str("对话")
	SceneManager.show_confirm_dialog(msg, actorId, mood)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(256)
	return

#转移
func ceil_trans_to_other_city():
	LoadControl.set_view_model(257);
	SceneManager.clear_bottom();
	DataManager.twinkle_citys.clear();
	var scene_affiars:Control = SceneManager.current_scene();
	var vstate_controlNo = DataManager.get_current_control_sort()
	var player:Player = DataManager.players[vstate_controlNo];
	scene_affiars.cursor.show();
	scene_affiars.set_city_cursor_position(DataManager.player_choose_city);
	SceneManager.show_unconfirm_dialog("向哪座城池转移？\n请指定");

func _ceil_persuade(vstateId:int, cityId:int, actorId:int, targetActorIds:PoolIntArray):
	var actor = ActorHelper.actor(actorId)
	var failed = []
	var persuaded = []
	var results = []
	for targetId in targetActorIds:
		# 默认进入招揽成功率计算
		var targetActor = ActorHelper.actor(targetId)
		var rate = PolicyCommand.get_canvass_rate(
			actor.actorId,
			targetActor.actorId,
			actor.get_politics(),
			actor.get_moral(),
			actor.get_level()
		)
		var expectedLoyalty = max(0, 79 - targetActor.get_loyalty())
		var result = 0
		if targetActor.get_prev_vstate_id() == vstateId:
			# 原势力，直接同意
			rate = 100
			expectedLoyalty = min(90, targetActor.get_loyalty())
		DataManager.set_env("提示", "尝试说服{0}\n成功率{1}%".format([
			targetActor.get_name(), rate,
		]))
		if Global.get_rate_result(rate):
			result = 1
			persuaded.append(targetActor.get_name())
			clCity.move_to(targetId, cityId)
			targetActor.set_status_officed()
			targetActor.set_loyalty(expectedLoyalty)
			# TODO
			# 这里立刻调用 10001 会产生问题，比如荐才中断流程，未来再考虑
			# SkillHelper.auto_trigger_skill(search_actorId, 10001, "")
		else:
			failed.append(targetActor.get_name())
		results.append(result)
	DataManager.set_env("结果", results)
	DataManager.set_env("动画", "Strategy_Talking")
	var msg = ""
	if not persuaded.empty():
		var cnt = persuaded.size()
		var suffix = ""
		if cnt > 1:
			suffix = "等{0}人".format([cnt])
		msg = "可喜可贺!\n{0}{1}已加入我方".format([persuaded[0], suffix])
	else:
		msg = "很遗憾!\n未能说服{0}".format([
			failed[0]
		])
	DataManager.common_variable["对话"] = msg
	return

# 流放
func _ceil_exile(vstateId:int, cityId:int, targetActorIds:PoolIntArray):
	var exiled = []
	var city = clCity.city(cityId)
	var targetCityIds = city.get_connected_city_ids()
	for targetId in targetActorIds:
		clCity.move_out(targetId)
		var actor = ActorHelper.actor(targetId)
		city.add_city_property("后备兵", actor.get_soldiers())
		actor.set_soldiers(0)
		targetCityIds.shuffle()
		var targetCityId = targetCityIds[0]
		var prevVstateId = actor.get_prev_vstate_id()
		if prevVstateId >= 0:
			var prevVstate = clVState.vstate(prevVstateId)
			if not prevVstate.is_perished():
				for prevVstateCity in clCity.all_cities([prevVstateId]):
					targetCityId = prevVstateCity.ID
					break
		exiled.append(actor.get_name())
		actor.set_status_exiled(-1, targetCityId)
		actor.set_loyalty(50)
		actor.set_dislike_vstate_id(vstateId)
	var suffix = ""
	var cnt = exiled.size();
	if cnt > 1:
		suffix = "等{0}人".format([cnt])
	var msg = "{0}{1}已被流放".format(["、".join(exiled.slice(0,7)), suffix])
	DataManager.common_variable["对话"] = msg
	return

# 斩首
func _ceil_execute(vstateId:int, cityId:int, targetActorIds:PoolIntArray):
	var executed = [];
	var city = clCity.city(cityId)
	for targetId in targetActorIds:
		clCity.move_out(targetId);
		var actor = ActorHelper.actor(targetId)
		city.add_city_property("后备兵", actor.get_soldiers())
		executed.append(actor.get_name())
		actor.set_status_dead()
		actor.set_hp(5)
		actor.set_soldiers(0)
		actor.set_dislike_vstate_id(vstateId)
	var suffix = ""
	var cnt = executed.size();
	if cnt > 1:
		suffix = "等{0}人".format([cnt])
	var msg = "{0}{1}已被斩首".format(["、".join(executed.slice(0,7)), suffix])
	DataManager.common_variable["对话"] = msg
	return

# 转移
func _ceil_transfer(vstateId:int, cityId:int, toCityId:int, targetActorIds:PoolIntArray):
	var transfered = []
	for targetId in targetActorIds:
		clCity.move_out(targetId)
		clCity.move_to_ceil(targetId, toCityId)
		var actor = ActorHelper.actor(targetId)
		transfered.append(actor.get_name())
	var suffix = ""
	var cnt = transfered.size();
	if cnt > 1:
		suffix = "等{0}人".format([cnt])
	var msg = "{0}{1}已被转移至{2}".format([
		"、".join(transfered.slice(0,7)), suffix,
		clCity.city(toCityId).get_name()
	])
	DataManager.set_env("对话", msg)
	return

# 释放
func _ceil_release(vstateId:int, cityId:int, targetActorIds:PoolIntArray):
	var released = []
	var exiled = []
	var city = clCity.city(cityId)
	var targetCityIds = city.get_connected_city_ids()
	for targetId in targetActorIds:
		clCity.move_out(targetId)
		var actor = ActorHelper.actor(targetId)
		actor.set_hp(max(10, actor.get_hp()))
		actor.set_soldiers(0)
		var prevVstateId = actor.get_prev_vstate_id()
		if prevVstateId >= 0:
			var prevVstate = clVState.vstate(prevVstateId)
			if not prevVstate.is_perished():
				var capital = clCity.get_capital_city(prevVstate.id)
				if capital != null:
					actor.set_status_officed()
					clCity.move_to(targetId, capital.ID)
					released.append([actor.get_name(), capital.get_full_name()])
					prevVstate.relation_index_change(vstateId, 10)
					continue
		targetCityIds.shuffle()
		var targetCityId = targetCityIds[0]
		actor.set_status_exiled(-1, targetCityId)
		exiled.append(actor.get_name())
		actor.set_loyalty(50)
	var msg = ""
	if not released.empty():
		msg += released[0][0]
		if released.size() == 1:
			msg += "已放归" + released[0][1]
		else:
			msg += "等{0}人已放归".format([released.size()])
	if not exiled.empty():
		msg += "\n" + exiled[0]
		if exiled.size() > 1:
			msg += "等{0}人".format([exiled.size()])
		msg += "已流放"
	DataManager.set_env("对话", msg)
	return
