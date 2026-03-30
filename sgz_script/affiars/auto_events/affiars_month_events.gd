extends Resource

const VIEW_MODEL_NAME = "内政-月事件-当前步骤"

# 读取当前步骤
func get_view_model() -> int:
	return DataManager.get_env_int(VIEW_MODEL_NAME)

# 设置当前步骤
func set_view_model(step:int) -> void:
	DataManager.set_env(VIEW_MODEL_NAME, step)
	return

func _init() -> void:
	FlowManager.bind_import_flow("harvest_finish", self)
	FlowManager.bind_import_flow("extra_harvest_gold", self)
	FlowManager.bind_import_flow("disaster_result", self)
	FlowManager.bind_import_flow("disaster_avoided", self)
	FlowManager.bind_import_flow("rebell_result", self)
	FlowManager.bind_import_flow("rebell_notice", self)
	return

func start() -> void:
	DataManager.game_trace("==== 月事件开始 {0}-{1} ====".format([
		DataManager.year, DataManager.month
	]))
	DataManager.unset_env("每月赋税势力")
	SceneManager.hide_all_tool()
	set_view_model(1)
	return

func end() -> void:
	set_view_model(-1)
	DataManager.game_trace("==== 月事件结束 {0}-{1} ====".format([
		DataManager.year, DataManager.month
	]))
	SceneManager.hide_all_tool()
	FlowManager.add_flow("vstate_init")
	return

func _process(delta: float) -> void:
	var vm = get_view_model()
	if vm < 0:
		return
	if FlowManager.has_task():
		return
	var method = "monthly_step_{0}".format([vm])
	if has_method(method):
		set_view_model(-1)
		call(method)
	elif has_method(method + "_delta"):
		set_view_model(-1)
		call(method + "_delta", delta)
	return

# @since 1.810，经济改革判断
func monthly_step_1() -> void:
	city_data_deal()

	var triggered = DataManager.get_env_int_array("每月赋税势力")
	var triggeredNames = []
	var monthLeft = 0
	for vs in clVState.all_vstates():
		if vs.is_perished():
			continue
		if vs.id in triggered:
			continue
		for buff in SkillRangeBuff.find_for_vstate("每月赋税", vs.id):
			monthLeft = max(monthLeft, int(buff.effectTagVal))
			if monthLeft <= 0:
				continue
			triggered.append(vs.id)
			triggeredNames.append(vs.get_lord_name())
			DataManager.set_env("每月赋税势力", triggered)
			break
	if triggered.size() > 0:
		var names = "、".join(triggeredNames)
		if triggeredNames.size() > 3:
			triggeredNames = triggeredNames.slice(0, 3)
			names = "、".join(triggeredNames)
			names += "等"
		var msg = "{0}势力币制改革\n剩余：{1}月\n持有金少量增加".format([
			names, monthLeft
		])
		SceneManager.play_affiars_animation("CollectMoney", "", false, msg)
		set_view_model(1001)
		return
	set_view_model(2)
	return

# 等待币制改革动画
func monthly_step_1001_delta(delta:float) -> void:
	if not Global.wait_for_confirmation("extra_harvest_gold", VIEW_MODEL_NAME, delta):
		set_view_model(1001)
	return

# 每月赋税
func extra_harvest_gold():
	SceneManager.cleanup_animations()
	FlowManager.flows_history_list.clear()
	var triggered = DataManager.get_env_int_array("每月赋税势力")
	for city in clCity.all_cities():
		if not city.get_vstate_id() in triggered:
			continue
		var money = _get_collect_money(city)
		money = int(ceil(money * 0.1))
		city.add_gold(money)
	set_view_model(2)
	return

# 收金收米判断
func monthly_step_2() -> void:
	var month = DataManager.month
	var resurrectMonth = -1
	var resurrectSetting = DataManager.get_game_setting("自动复活")
	match resurrectSetting:
		"全年":
			resurrectMonth = month
		"无":
			pass
		_:
			resurrectMonth = int(resurrectSetting.replace("月", ""))

	DataManager.game_trace("== 每月武将复活轮询 BEGIN。")
	var resurrected = []
	var resurrectedScore = -1
	if month == resurrectMonth:
		# 复活月份
		for actor in ActorHelper.all_dead_actors():
			actor.set_status_exiled(-1, -1)
			actor.set_hp(1)
			# 复活后不会在今年老死
			actor.set_life_limit(max(actor.get_life_limit(), DataManager.year + 1))
			actor.set_loyalty(50)
			if actor.get_exiled_city_id() < 0:
				actor.set_exile_city(clCity.random_city_id())
			resurrected.append(actor.actorId)
			var score = actor.get_power_score()
			if score > resurrectedScore:
				resurrectedScore = score
				resurrected.erase(actor.actorId)
				resurrected.insert(0, actor.actorId)
	DataManager.game_trace("== 每月武将复活轮询 END。")

	var anim = ""
	var msg = str(month) + "月 "
	match month:
		4:
			anim = "CollectMoney"
			msg += "收取税金\n持有金增加";
		10:
			anim = "CollectRice"
			msg += "稻米收成\n持有米增加"
		_:
			if resurrected.size() > 0:
				anim = "Town_Move"
				msg += "死者复生之季节"
	if anim == "":
		set_view_model(3)
		return

	if resurrected.size() > 0:
		#事件动画一定显示在左侧
		DataManager.player_choose_city = 0
		var actor = ActorHelper.actor(resurrected[0])
		if resurrected.size() == 1:
			msg += "\n{0}已转生".format([
				actor.get_name(),
			])
		else:
			msg += "\n{0}等{1}人已转生".format([
				actor.get_name(), resurrected.size(),
			])
	SceneManager.play_affiars_animation(anim, "", false, msg)
	set_view_model(2001)
	return

# 等待收获消息确认
func monthly_step_2001_delta(delta:float) -> void:
	if not Global.wait_for_confirmation("harvest_finish", VIEW_MODEL_NAME, delta):
		set_view_model(2001)
	return

# 收获确认
func harvest_finish():
	SceneManager.cleanup_animations()
	FlowManager.flows_history_list.clear()
	if DataManager.month == 4:
		var triggered = DataManager.get_env_int_array("每月赋税势力")
		for city in clCity.all_cities():
			if city.get_vstate_id() in triggered:
				continue
			var money = _get_collect_money(city)
			city.add_gold(money)
	elif DataManager.month == 10:
		for city in clCity.all_cities():
			var rice = _get_collect_rice(city)
			city.add_rice(rice)
	set_view_model(3)
	return

# 灾害
func monthly_step_3() -> void:
	SceneManager.hide_all_tool()
	DataManager.set_env("内政.灾害城市", [])
	#事件动画一定显示在左侧
	DataManager.player_choose_city = 0
	var disaterName = ""
	var anim = ""
	if DataManager.month in [5,6]:
		disaterName = "洪涝"
		anim = "Disaster_Waterlog"
	elif DataManager.month in [8,9]:
		disaterName = "旱灾"
		anim = "Disaster_Dry"
	else:
		set_view_model(4)
		return
	var disaterCityIds = []
	for city in clCity.all_cities():
		if city.get_vstate_id() < 0:
			continue
		if city.chance_for_disaster(disaterName):
			disaterCityIds.append(city.ID)
	if disaterCityIds.empty():
		set_view_model(4)
		return
	DataManager.set_env("内政.灾害类型", disaterName)
	DataManager.set_env("内政.灾害城市", disaterCityIds)
	var msg = "各地出现" + disaterName
	SceneManager.play_affiars_animation(anim, "", false, msg)
	set_view_model(3001)
	return

# 灾情通报确认
func monthly_step_3001_delta(delta:float) -> void:
	if not Global.wait_for_confirmation("disaster_result", VIEW_MODEL_NAME, delta):
		set_view_model(3001)
	return

# 具体灾害影响
func disaster_result() -> void:
	SceneManager.cleanup_animations()
	SceneManager.hide_all_tool()
	var disasterName = DataManager.get_env_str("内政.灾害类型")
	var disaterCityIds = DataManager.get_env_int_array("内政.灾害城市")
	if disaterCityIds.empty():
		set_view_model(4)
		return

	var city = clCity.city(disaterCityIds.pop_front())
	DataManager.set_env("内政.灾害城市", disaterCityIds)

	var damage = true
	if city.get_defence() >= 99:
		damage = false
		city.add_city_property("防灾", -Global.get_random(10, 20))
	else:
		# 损失比例
		var lossRate = 110 - city.get_defence()
		# 最大 20%
		lossRate = min(20, lossRate)
		# 最小 5%
		lossRate = max(5, lossRate)
		city.add_city_property("土地", -int(city.get_land() * lossRate / 100))
		city.add_city_property("产业", -int(city.get_eco() * lossRate / 100))
		city.add_city_property("人口", -int(city.get_pop() * lossRate / 100))
		for actorId in city.get_actor_ids():
			var actor = ActorHelper.actor(actorId)
			actor.set_soldiers(int(actor.get_soldiers() * (100 - lossRate) / 100))
	var leaderId = city.get_leader_id()
	if leaderId < 0:
		# 不汇报，继续处理下一个
		FlowManager.add_flow("disaster_result")
		return

	var reporter = leaderId
	var controlNo = DataManager.get_actor_controlNo(leaderId)
	if controlNo < 0:
		# 太守非玩家控制，判断君主
		controlNo = DataManager.get_actor_controlNo(city.get_lord_id())
	# 玩家非君主和太守时，寻找城内是否存在武将
	if controlNo < 0:
		for actorId in city.get_actor_ids():
			controlNo = DataManager.get_actor_controlNo(actorId)
			if controlNo >= 0:
				reporter = actorId
				break
	
	if controlNo < 0 or reporter < 0:
		# 无人汇报，继续处理下一个
		FlowManager.add_flow("disaster_result")
		return

	DataManager.twinkle_citys = [city.ID]
	DataManager.player_choose_city = city.ID
	DataManager.set_env("内政.灾害汇报", [city.ID, reporter])
	var msg = "大事不好\n{0}受到{1}影响".format([
		city.get_name(), disasterName
	])
	SceneManager.show_confirm_dialog(msg, reporter, 3)
	if damage:
		set_view_model(3002)
	else:
		set_view_model(3003)
	return

func monthly_step_3002_delta(delta:float) -> void:
	if not Global.wait_for_confirmation("disaster_result", VIEW_MODEL_NAME, delta):
		set_view_model(3002)
	return

func monthly_step_3003_delta(delta:float) -> void:
	if not Global.wait_for_confirmation("disaster_avoided", VIEW_MODEL_NAME, delta):
		set_view_model(3003)
	return

func disaster_avoided() -> void:
	SceneManager.cleanup_animations()
	var reporting = DataManager.get_env_int_array("内政.灾害汇报")
	var cityId = reporting[0]
	var reporter = reporting[1]
	var msg = "所幸有备无患\n{0}并未受到损失\n尚需补修防灾".format([
		clCity.city(cityId).get_full_name()
	])
	SceneManager.show_confirm_dialog(msg, reporter, 1)
	set_view_model(3002)
	return

# 检查暴动事件
func monthly_step_4() -> void:
	var rebellCityIds = []
	for city in clCity.all_cities():
		if city.get_vstate_id() < 0:
			continue
		if city.chance_for_rebellion():
			rebellCityIds.append(city.ID)
	DataManager.set_env("内政.暴动城市", rebellCityIds)
	if rebellCityIds.empty():
		set_view_model(5)
		return

	FlowManager.add_flow("rebell_result")
	return

func rebell_result() -> void:
	SceneManager.cleanup_animations()
	SceneManager.hide_all_tool()
	var rebellCityIds = DataManager.get_env_int_array("内政.暴动城市")
	if rebellCityIds.empty():
		set_view_model(5)
		return

	var city = clCity.city(rebellCityIds.pop_front())
	DataManager.set_env("内政.暴动城市", rebellCityIds)

	var result = Global.get_random(0, 2)
	# 随机损失 5% ~ 10%
	var lossRate = Global.get_random(5, 10)

	var resultMessage = ""
	match result:
		0: # 减人口
			city.add_city_property("人口", -int(city.get_pop() * lossRate / 100))
			resultMessage = "民众不堪忍受\n纷纷背井离乡"
		1: # 减金米
			city.add_gold(-int(city.get_gold() * lossRate / 100))
			city.add_rice(-int(city.get_rice() * lossRate / 100))
			resultMessage = "民众聚集，冲击官仓\n劫夺金米，一哄而散"
		2: # 减土地产业
			city.add_city_property("土地", -int(city.get_land() * lossRate / 100))
			city.add_city_property("产业", -int(city.get_eco() * lossRate / 100))
			resultMessage = "民众破坏产业\n抗议暴政"

	var leaderId = city.get_leader_id()
	if leaderId < 0:
		# 不汇报，继续处理下一个
		FlowManager.add_flow("rebell_result")
		return

	var reporter = leaderId
	var controlNo = DataManager.get_actor_controlNo(leaderId)
	if controlNo < 0:
		# 太守非玩家控制，判断君主
		controlNo = DataManager.get_actor_controlNo(city.get_lord_id())
	# 玩家非君主和太守时，寻找城内是否存在武将
	if controlNo < 0:
		for actorId in city.get_actor_ids():
			controlNo = DataManager.get_actor_controlNo(actorId)
			if controlNo >= 0:
				reporter = actorId
				break
	
	if controlNo < 0 or reporter < 0:
		# 无人汇报，继续处理下一个
		FlowManager.add_flow("rebell_result")
		return

	DataManager.twinkle_citys = [city.ID]
	DataManager.player_choose_city = city.ID
	var msg = "大事不好\n{0}发生叛乱!".format([city.get_name()])
	DataManager.set_env("内政.暴动汇报", [city.ID, reporter, resultMessage])
	SceneManager.play_affiars_animation("Disaster_Riot", "", false, msg, reporter)
	set_view_model(4001)
	return

# 确认暴动提示
func monthly_step_4001_delta(delta:float) -> void:
	if not Global.wait_for_confirmation("rebell_notice", VIEW_MODEL_NAME, delta):
		set_view_model(4001)
	return

# 汇报暴动影响
func rebell_notice() -> void:
	SceneManager.cleanup_animations()
	var reporting = DataManager.get_env_array("内政.暴动汇报")
	var cityId = int(reporting[0])
	var reporter = int(reporting[1])
	var msg = str(reporting[2])
	SceneManager.show_confirm_dialog(msg, reporter, 3)
	SceneManager.show_cityInfo(true, cityId, 1)
	set_view_model(4002)
	return

# 确认暴动影响，继续下一个
func monthly_step_4002_delta(delta:float) -> void:
	if not Global.wait_for_confirmation("rebell_result", VIEW_MODEL_NAME, delta):
		set_view_model(4002)
	return

# 检查统一
func monthly_step_5() -> void:
	for vs in clVState.all_vstates():
		if vs.is_perished():
			continue;
		var cityNum = DataManager.get_city_num_by_vstate(vs.id)
		if cityNum < clCity.all_city_ids().size():
			continue;
		# 占领全部城池后，显示统一画面
		SceneManager.hide_all_tool()
		set_view_model(-1)
		SceneManager.over_animation.play_unify(vs.id)
		return

	set_view_model(6)
	return

# 流放武将跑路
func monthly_step_6() -> void:
	for actor in ActorHelper.all_exiled_actors():
		var cityId = actor.get_exiled_city_id()
		if cityId < 0:
			continue
		if actor.get_dislike_vstate_id() == clCity.city(cityId).get_vstate_id():
			clCity.find_new_home(actor.actorId)
	set_view_model(7)
	return

# @since 2.19 势力关系变化
func monthly_step_7() -> void:
	# 玩家汇报
	var reporter = -1
	for p in DataManager.players:
		if p.actorId < 0:
			continue
		reporter = p.actorId
		break
	var changed = []
	if DataManager.month in [1, 4, 7, 10]:
		var vstates = clVState.all_vstates(true)
		for vs in vstates:
			var lord = ActorHelper.actor(vs.get_lord_id())
			# 目标势力
			var excludedVstateIds = [-1]
			# 所有城市
			for city in clCity.all_cities([vs.id]):
				# 判断邻接势力
				for targetId in city.get_connected_city_ids([], excludedVstateIds):
					var targetCity = clCity.city(targetId)
					var targetVstateId = targetCity.get_vstate_id()
					if targetVstateId == vs.id:
						continue
					var change = -5
					var targetLord = ActorHelper.actor(targetCity.get_lord_id())
					var distance = lord.personality_distance(targetLord)
					if vs.love(targetVstateId):
						change = 0
					elif vs.hate(targetVstateId):
						change = -10
					if distance <= 10:
						change = max(0, change)
					elif distance > 30:
						change -= 5
					elif distance > 50:
						change -= 10
					var memo = vs.get_relation_index_memo(targetVstateId)
					vs.relation_index_change(targetVstateId, change)
					if targetLord.actorId == reporter and vs.get_relation_index_memo(targetVstateId) != memo:
						changed.append(vs)
					excludedVstateIds.append(targetVstateId)
	if reporter >= 0 and changed.size() > 0:
		var city = DataManager.get_office_city_by_actor(reporter)
		var names = []
		var cities = []
		for vs in changed:
			var name = vs.get_lord_name()
			if name in names:
				continue
			names.append(name)
			cities.append_array(clCity.all_city_ids([vs.id]))
		if names.size() > 3:
			names = names.slice(0, 2)
		var msg = "与{0}等势力的关系\n似乎有所恶化……".format(["、".join(names)])
		SceneManager.show_confirm_dialog(msg, reporter, 2)
		DataManager.twinkle_citys = cities
		set_view_model(7001)
		return

	set_view_model(8)
	return

func monthly_step_7001_delta(delta:float) -> void:
	if not Global.wait_for_confirmation("", VIEW_MODEL_NAME, delta):
		set_view_model(7001)
		return
	set_view_model(8)
	return

func monthly_step_8() -> void:
	end()
	return

#获取4月可收取的金
func _get_collect_money(city)->int:
	var p_x = 50;
	var loy = city.get_loyalty()
	if loy >= 100:
		p_x = 100;
	elif loy >= 91:
		p_x = 90;
	elif loy >= 81:
		p_x = 80;
	elif loy >= 71:
		p_x = 70;
	elif loy >= 51:
		p_x = 60;
	var money = int((city.get_eco()/3+100)*city.get_pop()/100/80*p_x/100);
	return money;

#获取10月可收取的米
func _get_collect_rice(city)->int:
	var p_x = 50
	var loy = city.get_loyalty()
	if loy >= 100:
		p_x = 100
	elif loy >= 91:
		p_x = 90
	elif loy >= 81:
		p_x = 80
	elif loy >= 71:
		p_x = 70
	elif loy >= 51:
		p_x = 60
	var rice = int((city.get_land()/4+60)*city.get_pop()/100/60*p_x/100);
	return rice

func city_data_deal()->void:
	var month = DataManager.month

	for city in clCity.all_cities():
		# 每过1个月，战乱度-2
		var chaos = city.add_chaos_score(-2)
		if month == 1:
			chaos = city.add_chaos_score(-max(10, chaos*0.2))

		# 人口自然增长
		var point = int(100/max(1, chaos))*0.001 / 12 *(city.get_loyalty()/100.0)
		city.add_city_property("人口", int(city.get_pop() * point))

		# 城门恢复
		var leader = city.get_leader()
		if leader != null and leader.actorId >= 0:
			for doorPosition in city.get_all_door_position():
				var doorHP = city.get_door_hp(doorPosition)
				doorHP += leader.get_politics()
				city.set_door_hp(doorPosition, doorHP)

		# 武将状态、忠诚度、体力的恢复和校正
		# 每月加忠光环的配置值比较特殊，十位个位为上限，百位以上为修正值
		var buffLoyaltyUps = []
		for srb in SkillRangeBuff.find_for_city("每月加忠", city.ID):
			var val = int(srb.effectTagVal)
			if val == 0:
				continue
			var limit = val % 100
			limit = (100 + limit) % 100
			val = int(val / 100)
			buffLoyaltyUps.append([val, limit])
		for srb in SkillRangeBuff.find_for_vstate("每月加忠", city.get_vstate_id()):
			var val = int(srb.effectTagVal)
			if val == 0:
				continue
			var limit = val % 100
			limit = (100 + limit) % 100
			val = int(val / 100)
			buffLoyaltyUps.append([val, limit])
		for actorId in city.get_actor_ids():
			var actor = ActorHelper.actor(actorId)
			if actorId == city.get_lord_id():
				var vs = clVState.vstate(city.get_vstate_id())
				vs.set_capital_id(city.ID)
				actor.set_loyalty(100)
			else:
				actor.set_loyalty(min(99, actor.get_loyalty()))
			if not actor._has_attr("内政.离间"):
				if actor.get_loyalty() >=30 and actor.get_loyalty() < 70:
					actor.add_loyalty(3)
			actor._remove_attr("内政.离间")
			var change = 0
			for row in buffLoyaltyUps:
				if actor.get_loyalty() < row[1]:
					change += row[0]
			if change > 0:
				actor.add_loyalty(change)
			actor.set_status_officed(city.get_vstate_id())
			actor.set_dislike_vstate_id(-2)
			actor.set_exile_city(city.ID)
			actor.recover_hp(20, true)
		#DataManager.game_trace("--循环武将结束--");
		#DataManager.game_trace("--循环监狱开始--");
		#处理监狱武将
		for c_actorId in city.get_ceil_actor_ids():
			var c_actor = ActorHelper.actor(c_actorId)
			if c_actor.get_prev_vstate_id() != city.get_vstate_id():
				var decrease = min(5, 14 - int(c_actor.get_loyalty()/10))*2
				c_actor.add_loyalty(-decrease)
				c_actor.recover_hp(5)
				c_actor.set_soldiers(0)
			else:
				#原势力=当前势力的，过月时自动从监狱释放出来
				clCity.move_out(c_actorId);
				clCity.move_to(c_actorId,city.ID);
				c_actor.set_status_officed()
				if c_actor.get_loyalty() > 90:
					#防止原君主忠--
					c_actor.set_loyalty(90)
		#DataManager.game_trace("--循环监狱结束--");

	DataManager.set_env("大限检查", [])
	return
