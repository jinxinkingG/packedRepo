extends "res://script/clEnvBase.gd"

#AI-策略
func _init() -> void:
	LoadControl.view_model_name = "内政-AI-步骤"
	FlowManager.bind_import_flow("AI_Policy", self)

	FlowManager.bind_import_flow("rescue_notice", self)
	FlowManager.bind_import_flow("rescue_ask", self)
	FlowManager.bind_import_flow("rescue_refused", self)
	FlowManager.bind_import_flow("rescue_accepted", self)
	FlowManager.bind_import_flow("rescue_thank", self)
	FlowManager.bind_import_flow("rescue_success", self)
	FlowManager.bind_import_flow("rescue_failed", self)

	FlowManager.bind_import_flow("envoy_notice", self)
	FlowManager.bind_import_flow("envoy_ask", self)
	FlowManager.bind_import_flow("envoy_refused", self)
	FlowManager.bind_import_flow("envoy_accepted", self)
	FlowManager.bind_import_flow("envoy_success", self)
	FlowManager.bind_import_flow("envoy_failed", self)

	FlowManager.bind_import_flow("ally_1", self)
	FlowManager.bind_import_flow("ally_2", self)
	FlowManager.bind_import_flow("ally_3", self)

	FlowManager.bind_import_flow("wedge_1", self)

	FlowManager.bind_import_flow("canvass_1", self)

	FlowManager.bind_import_flow("incite_1", self)

	return

#按键操控
func _input_key(delta: float):
	var scene_affiars:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	match view_model:
		111:
			Global.wait_for_confirmation("ally_2", "", delta)
		112:
			Global.wait_for_yesno("ally_3", "AI_next")
		113:
			Global.wait_for_confirmation("AI_next", "", delta)
		121:
			Global.wait_for_confirmation("wedge_1", "", delta)
		131:
			Global.wait_for_confirmation("canvass_1", "", delta)
		141:
			Global.wait_for_confirmation("incite_1", "", delta)
		151:
			Global.wait_for_confirmation("envoy_ask", "", delta)
		152:
			Global.wait_for_yesno("envoy_accepted", "envoy_refused")
		153:
			Global.wait_for_confirmation("envoy_success", "", delta)
		154:
			Global.wait_for_confirmation("envoy_failed", "", delta)
		155:
			Global.wait_for_confirmation("AI_next", "", delta)
		161:
			Global.wait_for_confirmation("rescue_ask", "", delta)
		162:
			Global.wait_for_yesno("rescue_accepted", "rescue_refused")
		163:
			Global.wait_for_confirmation("rescue_thank", "", delta)
		164:
			Global.wait_for_confirmation("rescue_success", "", delta)
		165:
			Global.wait_for_confirmation("rescue_failed", "", delta)
		166:
			Global.wait_for_confirmation("AI_next", "", delta)
	return

func AI_Policy():
	LoadControl.set_view_model(100);
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no]
	var vs = clVState.vstate(vstateId)
	var methods = ["rescue", "envoy", "ally", "wedge", "canvass", "incite"]
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

#-------------俘虏请求逻辑--------------
func rescue()->bool:
	LoadControl.set_view_model(160)
	# 先定位玩家势力
	var playerVstateId = -1
	var playerId = -1
	for p in DataManager.players:
		if p.actorId < 0:
			continue
		playerId = p.actorId
		var cityId = DataManager.get_office_city_by_actor(playerId)
		if cityId >= 0:
			playerVstateId = clCity.city(cityId).get_vstate_id()
			break
	if playerVstateId < 0:
		return false
	var currentVstateId = DataManager.vstates_sort[DataManager.vstate_no]
	var currentVstate = clVState.vstate(currentVstateId)
	var currentTiming = DataManager.year * 12 + DataManager.month
	var capital = clCity.get_capital_city(currentVstate.id)
	# 只找被玩家俘虏的自势力武将
	for city in clCity.all_cities([playerVstateId]):
		for targetId in city.get_ceil_actor_ids():
			var targetActor = ActorHelper.actor(targetId)
			if targetActor.get_prev_vstate_id() != currentVstateId:
				continue
			# 上次请求时间
			var lastRescue = Global.intval(targetActor._get_attr("俘虏请求"))
			if lastRescue > 0 and currentTiming <= lastRescue + 3:
				continue
			# 寻找本势力最高政治的人
			var actionerId = DataManager.get_max_property_actorId("政", currentVstateId, [currentVstate.get_lord_id()])
			if actionerId < 0:
				continue
			# 记录请求时间
			targetActor._set_attr("俘虏请求", currentTiming)
			var cmd = DataManager.new_policy_command("交涉", actionerId, capital.ID)
			cmd.set_target(targetActor.actorId, city.ID)
			# 判断有没有可以交换的俘虏
			cmd.costRice = -1
			for myCity in clCity.all_cities([currentVstateId]):
				for capturedId in myCity.get_ceil_actor_ids():
					var captured = ActorHelper.actor(capturedId)
					if captured.get_prev_vstate_id() == cmd.target_vstate().id:
						cmd.costGold = capturedId
						cmd.costRice = myCity.ID
						break
			# 没有俘虏可换，使用金
			if cmd.costRice < 0:
				var gold = 150
				var score = targetActor.get_total_score()
				if score >= 300:
					gold = 250
				elif score >= 250:
					gold = 200
				gold += Global.get_random(1, 5) * 10
				cmd.costGold = gold
				# 先给 AI 加上
				cmd.city().add_gold(cmd.costGold)
			var ctrlNo = DataManager.get_actor_controlNo(playerId)
			FlowManager.set_current_control_playerNo(ctrlNo)
			FlowManager.add_flow("rescue_notice")
			return true
	return false

# 提示玩家
func rescue_notice():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "交涉":
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("AI_next")
		return

	var msg = "{0}大人\n{1}军之{2}前来觐见\n似有所请".format([
		cmd.target_vstate().get_lord_name(),
		cmd.vstate().get_dynasty_title_or_lord_name(),
		cmd.actioner().get_name(),
	])
	SceneManager.show_confirm_dialog(msg)
	LoadControl.set_view_model(161)
	return

# 玩家选择
func rescue_ask():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "交涉":
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("AI_next")
		return

	var msg = "{0}大人，代主公致意"
	if cmd.costRice >= 0:
		msg += "\n无意冒犯虎威，送还{4}"
	else:
		msg += "\n无意冒犯虎威，奉上金{1}"
	msg += "\n请求释放{2}的俘虏{3}"
	msg = msg.format([
		cmd.target_vstate().get_lord_name(), cmd.costGold,
		cmd.target_city().get_full_name(), cmd.target_actor().get_name(),
		ActorHelper.actor(cmd.costGold).get_name(),
	])
	var options = ["释放", "拒绝"]
	SceneManager.show_yn_dialog(msg, cmd.actioner().actorId, 1, options)
	SceneManager.actor_dialog.lsc.cursor_index = 1
	LoadControl.set_view_model(162)
	return

# 接受俘虏请求
func rescue_accepted():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "交涉":
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("AI_next")
		return

	var msg = "既如此 ……\n就如{0}所言，放归{1}\n再有触犯，定不容情".format([
		DataManager.get_actor_honored_title(cmd.actioner().actorId, cmd.target_vstate().get_lord_id()),
		cmd.target_actor().get_name(),
	])
	SceneManager.show_confirm_dialog(msg, cmd.target_vstate().get_lord_id(), 2)
	LoadControl.set_view_model(163)
	return

# 表示感谢
# 接受俘虏请求
func rescue_thank():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "交涉":
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("AI_next")
		return

	cmd.basicRate = 100
	cmd.rate = 100
	cmd.execute()

	# TODO, 这里没有使用 execute 产生的 message，暂时写死
	var ta = cmd.target_actor()
	ta._remove_attr("俘虏请求")
	var msg = "{0}大人宽宏，{1}必感念\n（{2}放归{3}"
	if cmd.costRice < 0:
		msg += "\n（{4}金增加 {5}"
	else:
		msg += "\n（{6}回到 {7}"
	msg = msg.format([
		cmd.target_vstate().get_lord_name(),
		ta.get_short_name(),
		ta.get_name(),
		cmd.city().get_full_name(),
		cmd.target_city().get_full_name(),
		cmd.costGold,
		ActorHelper.actor(cmd.costGold).get_name(),
		cmd.target_city().get_name(),
	])
	SceneManager.show_confirm_dialog(msg, ta.actorId, 1)
	LoadControl.set_view_model(164)
	return

# 接受俘虏请求的结果
func rescue_success():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "交涉":
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("AI_next")
		return

	var vs = cmd.vstate()
	var tv = cmd.target_vstate()
	# 关系变化
	var prevMemo = vs.get_relation_index_memo(tv.id)
	vs.relation_index_change(tv.id, 10)
	tv.relation_index_change(vs.id, 10)
	var memo = vs.get_relation_index_memo(tv.id)
	var msg = "{0}与{1}的关系略为改善"
	if memo != prevMemo:
		msg += "\n{1}对{0}的态度现为：{2}"
	msg = msg.format([
		tv.get_lord_name(),
		vs.get_lord_name(),
		memo
	])
	SceneManager.show_confirm_dialog(msg)
	LoadControl.set_view_model(166)
	return

# 拒绝请求俘虏
func rescue_refused():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "交涉":
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("AI_next")
		return

	var msg = "{0}所请，不合道理\n{1}岂可轻纵".format([
		DataManager.get_actor_honored_title(cmd.actioner().actorId, cmd.target_vstate().get_lord_id()),
		cmd.target_actor().get_name(),
	])
	SceneManager.show_confirm_dialog(msg, cmd.target_vstate().get_lord_id(), 2)
	LoadControl.set_view_model(165)
	return

# 拒绝亲善的结果
func rescue_failed():
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.type != "交涉":
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("AI_next")
		return

	var vs = cmd.vstate()
	var tv = cmd.target_vstate()
	# 关系变化
	var prevMemo = vs.get_relation_index_memo(tv.id)
	vs.relation_index_change(tv.id, -20)
	tv.relation_index_change(vs.id, -20)
	var memo = vs.get_relation_index_memo(tv.id)
	var msg = "{0}与{1}的关系显著恶化"
	if memo != prevMemo:
		msg += "\n{1}对{0}的态度现为：{2}"
	msg = msg.format([
		tv.get_lord_name(),
		vs.get_lord_name(),
		memo
	])
	SceneManager.show_confirm_dialog(msg)
	LoadControl.set_view_model(166)
	return

#-------------亲善逻辑--------------
func envoy()->bool:
	LoadControl.set_view_model(150)
	# 每月最多一次
	if DataManager.get_env_int("内政.MONTHLY.AI亲善") > 0:
		return false
	if not Global.get_rate_result(30):
		return false
	var currentVstateId = DataManager.vstates_sort[DataManager.vstate_no];
	var currentVstate = clVState.vstate(currentVstateId)
	var currentLord = ActorHelper.actor(currentVstate.get_lord_id())
	for vs in clVState.all_vstates(true):
		if vs.id == currentVstate.id:
			continue
		if not currentVstate.love(vs.id):
			# 非友好势力，跳过
			continue
		# 关系太差跳过
		if currentVstate.get_relation_index(vs.id) < 40:
			continue
		# 关系已经很好了，跳过
		if vs.get_relation_index(vs.id) >= 80:
			continue
		var ctrlNo = DataManager.get_actor_controlNo(vs.get_lord_id())
		if ctrlNo < 0:
			# AI 目标暂不发动
			continue
		# 寻找本势力最高政治的人
		var actionerId = DataManager.get_max_property_actorId("政", currentVstateId, [currentLord.actorId])
		if actionerId < 0:
			continue
		DataManager.player_choose_actor = actionerId
		DataManager.set_env("值", vs.id)
		FlowManager.set_current_control_playerNo(ctrlNo)
		FlowManager.add_flow("envoy_notice")
		return true
	return false

#提示玩家
func envoy_notice():
	# 每月最多一次
	DataManager.set_env("内政.MONTHLY.AI亲善", 1)
	var currentVstateId = DataManager.vstates_sort[DataManager.vstate_no]
	var currentVstate = clVState.vstate(currentVstateId)
	var chooseActor = ActorHelper.actor(DataManager.player_choose_actor)
	var selectVstateId = DataManager.get_env_int("值")
	var selectVstate = clVState.vstate(selectVstateId)
	var msg = "{0}大人\n{1}军之{2}以亲善使者身份前来觐见".format([
		selectVstate.get_lord_name(), currentVstate.get_dynasty_title_or_lord_name(), chooseActor.get_name()
	])
	SceneManager.show_confirm_dialog(msg)
	LoadControl.set_view_model(151)
	return

#玩家选择
func envoy_ask():
	var currentVstateId = DataManager.vstates_sort[DataManager.vstate_no]
	var currentVstate = clVState.vstate(currentVstateId)
	var chooseActor = ActorHelper.actor(DataManager.player_choose_actor)
	var selectVstateId = DataManager.get_env_int("值")
	var selectVstate = clVState.vstate(selectVstateId)

	var gold = Global.get_random(2, 5) * 50
	var rice = Global.get_random(2, 5) * 50
	DataManager.set_env("内政.亲善资源", [gold, rice])

	var msg = "{0}大人，代主公致意\n奉上金{1}、米{2}\n略表{3}大人心意".format([
		selectVstate.get_lord_name(), gold, rice,
		currentVstate.get_lord_name(),
	])
	var options = ["欣然接受", "冷淡拒绝"]
	SceneManager.show_yn_dialog(msg, chooseActor.actorId, 1, options)
	LoadControl.set_view_model(152)
	return

# 接受亲善
func envoy_accepted():
	var currentVstateId = DataManager.vstates_sort[DataManager.vstate_no]
	var currentVstate = clVState.vstate(currentVstateId)
	var chooseActor = ActorHelper.actor(DataManager.player_choose_actor)
	var selectVstateId = DataManager.get_env_int("值")
	var selectVstate = clVState.vstate(selectVstateId)

	var goods = DataManager.get_env_int_array("内政.亲善资源")
	var capital = clCity.get_capital_city(selectVstateId)
	capital.add_gold(goods[0])
	capital.add_rice(goods[1])

	var msg = "{0}远来辛苦\n多承{1}大人美意\n定要代为致意".format([
		DataManager.get_actor_honored_title(chooseActor.actorId, selectVstate.get_lord_id()),
		currentVstate.get_lord_name(),
	])
	SceneManager.show_confirm_dialog(msg, selectVstate.get_lord_id(), 1)
	LoadControl.set_view_model(153)
	return

# 接受亲善的结果
func envoy_success():
	var currentVstateId = DataManager.vstates_sort[DataManager.vstate_no]
	var currentVstate = clVState.vstate(currentVstateId)
	var chooseActor = ActorHelper.actor(DataManager.player_choose_actor)
	var selectVstateId = DataManager.get_env_int("值")
	var selectVstate = clVState.vstate(selectVstateId)

	# 关系变化
	var prevMemo = currentVstate.get_relation_index_memo(selectVstateId)
	selectVstate.relation_index_change(currentVstateId, 10)
	currentVstate.relation_index_change(selectVstateId, 10)
	var memo = currentVstate.get_relation_index_memo(selectVstateId)
	var msg = "{0}与{1}的关系略为改善"
	if memo != prevMemo:
		msg += "\n{1}对{0}的态度现为：{2}"
	msg = msg.format([
		selectVstate.get_lord_name(),
		currentVstate.get_lord_name(),
		memo
	])
	SceneManager.show_confirm_dialog(msg)
	LoadControl.set_view_model(155)
	return

# 拒绝亲善
func envoy_refused():
	var currentVstateId = DataManager.vstates_sort[DataManager.vstate_no]
	var currentVstate = clVState.vstate(currentVstateId)
	var chooseActor = ActorHelper.actor(DataManager.player_choose_actor)
	var selectVstateId = DataManager.get_env_int("值")
	var selectVstate = clVState.vstate(selectVstateId)

	var msg = "{0}劳苦，然虚礼可免\n吾军早晚一扫六合\n回复{1}大人，小心自保".format([
		DataManager.get_actor_honored_title(chooseActor.actorId, selectVstate.get_lord_id()),
		currentVstate.get_lord_name(),
	])
	SceneManager.show_confirm_dialog(msg, selectVstate.get_lord_id(), 2)
	LoadControl.set_view_model(154)
	return

# 拒绝亲善的结果
func envoy_failed():
	var currentVstateId = DataManager.vstates_sort[DataManager.vstate_no]
	var currentVstate = clVState.vstate(currentVstateId)
	var chooseActor = ActorHelper.actor(DataManager.player_choose_actor)
	var selectVstateId = DataManager.get_env_int("值")
	var selectVstate = clVState.vstate(selectVstateId)

	# 关系变化
	var prevMemo = currentVstate.get_relation_index_memo(selectVstateId)
	selectVstate.relation_index_change(currentVstateId, -20)
	currentVstate.relation_index_change(selectVstateId, -20)
	var memo = currentVstate.get_relation_index_memo(selectVstateId)
	var msg = "{0}与{1}的关系显著恶化"
	if memo != prevMemo:
		msg += "\n{1}对{0}的态度现为：{2}"
	msg = msg.format([
		selectVstate.get_lord_name(),
		currentVstate.get_lord_name(),
		memo
	])
	SceneManager.show_confirm_dialog(msg)
	LoadControl.set_view_model(155)
	return

#-------------同盟逻辑--------------
func ally()->bool:
	LoadControl.set_view_model(110)
	# AI执行同盟有固定的时间点
	if not DataManager.month in [1, 4, 7, 10]:
		return false
	var currentVstateId = DataManager.vstates_sort[DataManager.vstate_no];
	var currentVstate = clVState.vstate(currentVstateId)
	var currentLord = ActorHelper.actor(currentVstate.get_lord_id())
	var maxRate = 0
	var selectVstateId:int = -1
	for vs in clVState.all_vstates(true):
		# 跳过本身
		if vs.id == currentVstateId:
			continue
		# 已经在同盟的跳过
		if 0 < clVState.get_alliance_month(vs.id, currentVstateId):
			continue
		# 关系不好的跳过
		var idx = currentVstate.get_relation_index(vs.id)
		if idx <= 50:
			continue
		var vstateLord = ActorHelper.actor(vs.get_lord_id())
		var allyRate = DataManager.get_city_num_by_vstate(vs.id) + int((vstateLord.get_politics() + vstateLord.get_moral() - currentLord.get_wisdom()) / 3);
		if allyRate > maxRate:
			maxRate = allyRate
			selectVstateId = vs.id
	if maxRate <= 30:
		return false
	var selectVstate = clVState.vstate(selectVstateId)
	var selectLord = ActorHelper.actor(selectVstate.get_lord_id())
	if not Global.get_rate_result(maxRate):
		return false
	var select_lord_controlNo = DataManager.get_actor_controlNo(selectLord.actorId);
	if select_lord_controlNo < 0:
		var month = 6
		clVState.set_alliance(currentVstateId, selectVstateId, month)
		var reporter = -1
		for p in DataManager.players:
			if p.actorId < 0:
				continue
			reporter = p.actorId
			break
		if reporter >= 0:
			var cities = clCity.all_city_ids([currentVstate.id, selectVstate.id])
			var capital = clCity.get_capital_city(currentVstate.id)
			var msg = "据报：\n{0}与{1}已结盟{2}个月".format([
				currentVstate.get_lord_name(),
				selectVstate.get_lord_name(),
				month
			])
			capital.attach_free_dialog(msg, reporter, 2, cities)
		return false
	#寻找本势力最高智力的人
	var max_int = 0
	var max_int_actorId = DataManager.get_max_property_actorId("知", currentVstateId)
	DataManager.player_choose_actor = max_int_actorId;
	DataManager.common_variable["值"] = selectVstateId;
	FlowManager.set_current_control_playerNo(select_lord_controlNo);
	FlowManager.add_flow("ally_1")
	return true
	
#提示玩家
func ally_1():
	LoadControl.set_view_model(111)
	var currentVstateId = DataManager.vstates_sort[DataManager.vstate_no]
	var currentVstate = clVState.vstate(currentVstateId)
	var chooseActor = ActorHelper.actor(DataManager.player_choose_actor)
	var selectVstateId = DataManager.get_env_int("值")
	var selectVstate = clVState.vstate(selectVstateId)
	var msg = "{0}大人\n{1}军之{2}以同盟使者身份前来觐见".format([
		selectVstate.get_lord_name(), currentVstate.get_dynasty_title_or_lord_name(), chooseActor.get_name()
	])
	SceneManager.show_confirm_dialog(msg)

#玩家选择
func ally_2():
	LoadControl.set_view_model(112);
	var currentVstateId = DataManager.vstates_sort[DataManager.vstate_no]
	var currentVstate = clVState.vstate(currentVstateId)
	var chooseActor = ActorHelper.actor(DataManager.player_choose_actor)
	var selectVstateId = DataManager.get_env_int("值")
	var selectVstate = clVState.vstate(selectVstateId)
	
	var msg = "{0}大人，代主公致意\n为了两家友好，{1}大人愿与您结成同盟，可否?".format([
		selectVstate.get_lord_name(), currentVstate.get_lord_name(),
	])
	SceneManager.show_yn_dialog(msg, chooseActor.actorId)
	return

#结盟成功
func ally_3():
	LoadControl.set_view_model(113);
	var currentVstateId = DataManager.vstates_sort[DataManager.vstate_no]
	var currentVstate = clVState.vstate(currentVstateId)
	var chooseActor = ActorHelper.actor(DataManager.player_choose_actor)
	var selectVstateId = DataManager.get_env_int("值")
	var selectVstate = clVState.vstate(selectVstateId)
	clVState.set_alliance(currentVstateId, selectVstateId, 6)
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

	### 测试 AI 招揽，可使用以下几行
	### targetVstateId = 4
	### targetCityId = 7
	### targetActorId = 25

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
	LoadControl.set_view_model(141)
	return
