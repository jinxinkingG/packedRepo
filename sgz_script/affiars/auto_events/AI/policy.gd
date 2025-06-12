extends "res://script/clEnvBase.gd"

#AI-策略
func _init() -> void:
	LoadControl.view_model_name = "内政-AI-步骤";
	FlowManager.bind_import_flow("AI_Policy",self,"AI_Policy");
	FlowManager.bind_import_flow("ally_1",self,"ally_1");
	FlowManager.bind_import_flow("ally_2",self,"ally_2");
	FlowManager.bind_import_flow("ally_3",self,"ally_3");
	FlowManager.bind_import_flow("wedge",self,"wedge");
	FlowManager.bind_import_flow("wedge_1",self,"wedge_1");
	FlowManager.bind_import_flow("canvass",self,"canvass");
	FlowManager.bind_import_flow("canvass_1",self,"canvass_1");
	FlowManager.bind_import_flow("incite",self,"incite");
	FlowManager.bind_import_flow("incite_1",self,"incite_1");
	return

#按键操控
func _input_key(delta: float):
	var scene_affiars:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	match view_model:
		111:
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				FlowManager.add_flow("ally_2");
		112:
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
						FlowManager.add_flow("ally_3");
					1:
						FlowManager.add_flow("AI_next");
		113:
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				FlowManager.add_flow("AI_next");
		121:
			if not Global.is_action_pressed_AX():
				return
			if not SceneManager.dialog_msg_complete(true):
				return
			LoadControl.set_view_model(-1)
			FlowManager.add_flow("wedge_1")
		131:
			if not Global.is_action_pressed_AX():
				return
			if not SceneManager.dialog_msg_complete(true):
				return
			LoadControl.set_view_model(-1)
			FlowManager.add_flow("canvass_1")
		141:
			if DataManager.is_autoplay_mode():
				var accumulated = DataManager.get_env_float("delta")
				DataManager.set_env("delta", accumulated + delta)
				if accumulated >= 2.0 * Engine.time_scale:
					SceneManager.dialog_msg_complete(true)
					LoadControl.set_view_model(-1)
					FlowManager.add_flow("incite_1")
					return
			if not Global.is_action_pressed_AX():
				return
			if not SceneManager.dialog_msg_complete(true):
				return
			LoadControl.set_view_model(-1)
			FlowManager.add_flow("incite_1")
	return

func AI_Policy():
	LoadControl.set_view_model(100);
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no]
	var vs = clVState.vstate(vstateId)
	var methods = ["ally","wedge","canvass","incite"]
	methods.shuffle()
	var method = methods[0]
	if call(method):
		# 执行等待通知结果
		return
	FlowManager.add_flow("AI_next")
	DataManager.game_trace("  {0}AI策略结束:{1}，命令书{2}".format([
		vs.get_lord_name(), method, DataManager.orderbook,
	]))
	return

#-------------同盟逻辑--------------
func ally()->bool:
	LoadControl.set_view_model(110);
	var goRate = Global.get_rate_result(50);#AI执行同盟的概率50%
	if(!goRate):
		return false;
	var currentVstateId = DataManager.vstates_sort[DataManager.vstate_no];
	var currentVstate = clVState.vstate(currentVstateId)
	var currentLord = ActorHelper.actor(currentVstate.get_lord_id())
	var maxRate = 0;
	var selectVstateId:int = -1;
	for vs in clVState.all_vstates():
		#跳过本身
		if vs.id == currentVstateId:
			continue
		#势力灭亡的跳过
		if vs.is_perished():
			continue
		#已经在同盟的跳过
		if 0 < clVState.get_alliance_month(vs.id, currentVstateId):
			continue;
		var vstateLord = ActorHelper.actor(vs.get_lord_id())
		var allyRate = DataManager.get_city_num_by_vstate(vs.id) + int((vstateLord.get_politics() + vstateLord.get_moral() - currentLord.get_wisdom()) / 3);
		if (allyRate > maxRate):
			selectVstateId = vs.id
	if(maxRate<=30):
		return false;
	var selectVstate = clVState.vstate(selectVstateId)
	var selectLord = ActorHelper.actor(selectVstate.get_lord_id())
	if(!Global.get_rate_result(maxRate)):
		return false;
	var select_lord_controlNo = DataManager.get_actor_controlNo(selectLord.actorId);
	if(select_lord_controlNo<0):
		clVState.set_alliance(currentVstateId, selectVstateId, 6);
		return false;
	#寻找本势力最高智力的人
	var max_int = 0;
	var max_int_actorId = DataManager.get_max_property_actorId("知", currentVstateId);
	DataManager.player_choose_actor = max_int_actorId;
	DataManager.common_variable["值"] = selectVstateId;
	FlowManager.set_current_control_playerNo(select_lord_controlNo);
	FlowManager.add_flow("ally_1");
	return true;
	
#提示玩家
func ally_1():
	LoadControl.set_view_model(111);
	var currentVstateId = DataManager.vstates_sort[DataManager.vstate_no];
	var currentVstate = clVState.vstate(currentVstateId)
	var chooseActor = ActorHelper.actor(DataManager.player_choose_actor)
	var selectVstateId = int(DataManager.common_variable["值"]);
	var selectVstate = clVState.vstate(selectVstateId)
	var msg = "{0}大人\n{1}军之{2}以同盟使者身份前来觐见".format([
		selectVstate.get_lord_name(), currentVstate.get_dynasty_title_or_lord_name(), chooseActor.get_name()
	])
	SceneManager.show_confirm_dialog(msg)

#玩家选择
func ally_2():
	LoadControl.set_view_model(112);
	var currentVstateId = DataManager.vstates_sort[DataManager.vstate_no];
	var currentVstate = clVState.vstate(currentVstateId)
	var chooseActor = ActorHelper.actor(DataManager.player_choose_actor)
	var selectVstateId = int(DataManager.common_variable["值"]);
	var selectVstate = clVState.vstate(selectVstateId)
	
	var msg = "{0}大人\n为了两国友好\n结成同盟可否?".format([selectVstate.get_lord_name()])
	SceneManager.show_yn_dialog(msg, chooseActor.actorId)
	return

#结盟成功
func ally_3():
	LoadControl.set_view_model(113);
	var currentVstateId = DataManager.vstates_sort[DataManager.vstate_no];
	var currentVstate = clVState.vstate(currentVstateId)
	var chooseActor = ActorHelper.actor(DataManager.player_choose_actor)
	var selectVstateId = int(DataManager.common_variable["值"]);
	var selectVstate = clVState.vstate(selectVstateId)
	clVState.set_alliance(currentVstateId, selectVstateId, 6);
	SceneManager.show_confirm_dialog("与{0}军结为同盟".format([
		currentVstate.get_dynasty_title_or_lord_name()
	]))
	return

#-------------离间逻辑----------------
func wedge()->bool:
	LoadControl.set_view_model(120)
	#AI方
	var currentVstateId = DataManager.vstates_sort[DataManager.vstate_no]

	#(目标势力-int,目标武将-int)
	var dicTargetActors = DataManager.get_env_dict("AI.离间人员")
	var vsKey = str(currentVstateId)
	var targetActorId = -1
	var targetCityId = -1
	var targetVstateId = -1
	if dicTargetActors.has(vsKey):
		if not dicTargetActors[vsKey].empty():
			#判断已经离间过的目标是否合法
			targetActorId = int(dicTargetActors[vsKey]["目标武将"])
			targetCityId = DataManager.get_office_city_by_actor(targetActorId)
			targetVstateId = int(dicTargetActors[vsKey]["目标势力"])
			if targetCityId < 0:
				dicTargetActors.erase(vsKey)
			else:
				var targetCity = clCity.city(targetCityId)
				var actor = ActorHelper.actor(targetActorId)
				if actor.get_loyalty() >= 80 or targetCity.get_vstate_id() != targetVstateId or not actor.is_status_officed():
					dicTargetActors.erase(vsKey)
		else:
			dicTargetActors.erase(vsKey)
	if not dicTargetActors.has(vsKey):
		dicTargetActors[vsKey] = {}
		#寻找忠+(-30~30)（浮动值）后，数额最小的武将
		var minLoyalty = 1000
		targetActorId = -1
		var allCities = clCity.all_cities()
		for i in 5:
			allCities.shuffle()
			var city = allCities[0]
			if city.get_vstate_id() in [-1, currentVstateId]:
				continue
			for actorId in city.get_actor_ids():
				var actor = ActorHelper.actor(actorId)
				var loy = actor.get_loyalty()
				if loy >= 80 or loy < 20:
					continue
				loy = max(0, loy + Global.get_random(0, 20) - 10)
				if loy < minLoyalty:
					minLoyalty = loy
					targetActorId = actorId
					targetCityId = city.ID
					targetVstateId = city.get_vstate_id()
	if targetActorId < 0:
		return false

	var fromActorId = DataManager.get_max_property_actorId("政", currentVstateId)
	if fromActorId == -1:
		fromActorId = clVState.vstate(currentVstateId).get_lord_id()
	DataManager.player_choose_city = DataManager.get_office_city_by_actor(fromActorId)
	DataManager.player_choose_actor = targetActorId
	var cmd = DataManager.new_policy_command("离间", fromActorId)
	cmd.set_target(targetActorId, targetCityId)
	cmd.prepare()
	cmd.execute()

	if cmd.result > 0:
		# 成功则更新字典并标记武将
		dicTargetActors[vsKey] = {"目标武将":targetActorId, "目标势力":targetVstateId}
		DataManager.set_env("AI.离间人员", dicTargetActors)
		cmd.target_actor()._set_attr("内政.离间", 1)

	var targetControlNO = DataManager.get_actor_controlNo(clVState.vstate(targetVstateId).get_lord_id())
	if targetControlNO < 0:
		# 目标势力非玩家，不汇报
		return false

	# 进入汇报
	FlowManager.add_flow("wedge_1")
	return true

#循环确认对话即可
func wedge_1():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "离间":
		DataManager.twinkle_citys = []
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("AI_next")
		return

	var d = cmd.pop_result_dialog()
	if d == null:
		DataManager.twinkle_citys = []
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("AI_next")
		return

	DataManager.twinkle_citys = [d.cityId]
	SceneManager.show_confirm_dialog(d.msg, d.actorId, d.mood)
	LoadControl.set_view_model(121)
	return
	
#--------------招揽逻辑------------------
func canvass():
	LoadControl.set_view_model(130)
	var currentVstateId = DataManager.vstates_sort[DataManager.vstate_no]

	#(目标势力-int,目标武将-int)
	var dicTargetActors = DataManager.get_env_dict("AI.招揽人员")
	var vsKey = str(currentVstateId)
	var targetActorId = -1
	var targetCityId = -1
	var targetVstateId = -1
	if dicTargetActors.has(vsKey):
		if not dicTargetActors[vsKey].empty():
			#判断已经招揽过的目标是否合法
			targetActorId = int(dicTargetActors[vsKey]["目标武将"])
			targetCityId = DataManager.get_office_city_by_actor(targetActorId)
			targetVstateId = int(dicTargetActors[vsKey]["目标势力"])
			if targetCityId < 0:
				dicTargetActors.erase(vsKey)
			else:
				var targetCity = clCity.city(targetCityId)
				var actor = ActorHelper.actor(targetActorId)
				if actor.get_loyalty() >= 40 or targetCity.get_vstate_id() != targetVstateId or not actor.is_status_officed():
					dicTargetActors.erase(vsKey)
		else:
			dicTargetActors.erase(vsKey)
	if not dicTargetActors.has(vsKey):
		dicTargetActors[vsKey] = {}
		#寻找忠+(-30~30)（浮动值）后，数额最小的武将
		var minLoyalty = 1000
		targetActorId = -1
		var allCities = clCity.all_cities()
		for i in 5:
			allCities.shuffle()
			var city = allCities[0]
			if city.get_vstate_id() in [-1, currentVstateId]:
				continue
			for actorId in city.get_actor_ids():
				var actor = ActorHelper.actor(actorId)
				var loy = actor.get_loyalty()
				if loy >= 40:
					continue
				loy = max(0, loy + Global.get_random(0, 60) - 30)
				if loy < minLoyalty:
					minLoyalty = loy
					targetActorId = actorId
					targetCityId = city.ID
					targetVstateId = city.get_vstate_id()
	if targetActorId < 0:
		return false

	var fromActorId = DataManager.get_max_property_actorId("政", currentVstateId)
	DataManager.player_choose_city = DataManager.get_office_city_by_actor(fromActorId)
	DataManager.player_choose_actor = targetActorId
	var cmd = DataManager.new_policy_command("招揽", fromActorId)
	cmd.set_target(targetActorId, targetCityId)
	cmd.prepare()
	cmd.execute()

	if cmd.result > 0:
		# 成功则更新字典并标记武将
		dicTargetActors[vsKey] = {"目标武将":targetActorId, "目标势力":targetVstateId}
		DataManager.set_env("AI.招揽人员", dicTargetActors)

	var targetControlNO = DataManager.get_actor_controlNo(clVState.vstate(targetVstateId).get_lord_id())
	if targetControlNO < 0:
		# 目标势力非玩家，不汇报
		return false

	# 进入汇报
	FlowManager.add_flow("canvass_1")
	return true

#循环确认对话即可
func canvass_1():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "招揽":
		DataManager.twinkle_citys = []
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("AI_next")
		return

	var d = cmd.pop_result_dialog()
	if d == null:
		DataManager.twinkle_citys = []
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("AI_next")
		return

	DataManager.twinkle_citys = [d.cityId]
	SceneManager.show_confirm_dialog(d.msg, d.actorId, d.mood)
	LoadControl.set_view_model(131)
	return

#--------------挑唆逻辑------------------
func incite():
	LoadControl.set_view_model(140)
	#AI方
	var currentVstateId = DataManager.vstates_sort[DataManager.vstate_no]

	#(目标势力-int,目标武将-int)
	var dicTargetActors = DataManager.get_env_dict("AI.策反人员")
	var vsKey = str(currentVstateId)
	var targetActorId = -1
	var targetCityId = -1
	var targetVstateId = -1
	if dicTargetActors.has(vsKey):
		if not dicTargetActors[vsKey].empty():
			#判断已经策反过的目标是否合法
			targetActorId = int(dicTargetActors[vsKey]["目标武将"])
			targetCityId = DataManager.get_office_city_by_actor(targetActorId)
			targetVstateId = int(dicTargetActors[vsKey]["目标势力"])
			if targetCityId < 0:
				dicTargetActors.erase(vsKey)
			else:
				var targetCity = clCity.city(targetCityId)
				var actor = ActorHelper.actor(targetActorId)
				if actor.get_loyalty() >= 40 \
					or targetCity.get_vstate_id() != targetVstateId \
					or targetCity.get_actor_ids().find(targetActorId) != 0 \
					or not actor.is_status_officed():
					dicTargetActors.erase(vsKey)
		else:
			dicTargetActors.erase(vsKey)
	if not dicTargetActors.has(vsKey):
		dicTargetActors[vsKey] = {}
		#寻找忠+(-30~30)（浮动值）后，数额最小的武将
		var minLoyalty = 1000
		targetActorId = -1
		var allCities = clCity.all_cities()
		for i in 5:
			allCities.shuffle()
			var city = allCities[0]
			if city.get_vstate_id() in [-1, currentVstateId]:
				continue
			if city.get_actors_count() == 0:
				continue
			var actorId = city.get_actor_ids()[0]
			var actor = ActorHelper.actor(actorId)
			var loy = actor.get_loyalty()
			if loy >= 40:
				continue
			loy = max(0, loy + Global.get_random(0, 60) - 30)
			if loy < minLoyalty:
				minLoyalty = loy
				targetActorId = actorId
				targetCityId = city.ID
				targetVstateId = city.get_vstate_id()
	if targetActorId < 0:
		return false

	var fromActorId = DataManager.get_max_property_actorId("政", currentVstateId)
	DataManager.player_choose_city = DataManager.get_office_city_by_actor(fromActorId)
	DataManager.player_choose_actor = targetActorId
	var cmd = DataManager.new_policy_command("策反", fromActorId)
	cmd.set_target(targetActorId, targetCityId)
	cmd.prepare()
	cmd.execute()

	if cmd.result > 0:
		# 成功则更新字典并标记武将
		dicTargetActors[vsKey] = {"目标武将":targetActorId, "目标势力":targetVstateId}
		DataManager.set_env("AI.策反人员", dicTargetActors)

	# 进入汇报
	FlowManager.add_flow("incite_1")
	return true

#循环确认对话即可
func incite_1():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "策反":
		DataManager.twinkle_citys = []
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("AI_next")
		return

	var d = cmd.pop_result_dialog()
	if d == null:
		DataManager.twinkle_citys = []
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("AI_next")
		return

	DataManager.twinkle_citys = [d.cityId]
	SceneManager.show_confirm_dialog(d.msg, d.actorId, d.mood)
	DataManager.set_env("delta", 0)
	LoadControl.set_view_model(141)
	return
