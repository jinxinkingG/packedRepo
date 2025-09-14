extends Node

#AI核心战略
func _init() -> void:
	pass
	
#获取攻击路线
func search_way(vstateId:int,start_cityId:int,goal_cityId:int)->Array:
	var r = _get_next_target_route(vstateId);
	return r

#取出代价最小的城池ID
func _pop_min_value_key_by_dic(frontier_cost:Dictionary):
	var min_value = -1;
	var min_value_key = "";
	for key in frontier_cost:
		var value = frontier_cost[key];
		if(min_value==-1 || min_value>value):
			min_value = value;
			min_value_key = key;
	frontier_cost.erase(min_value_key);
	return min_value_key;

#预估代价，根据城池坐标远近预估代价
func _heuristic(from:int, goal:int):
	var fromCity = clCity.city(from)
	var toCity = clCity.city(goal)
	return abs(fromCity.get_location().x - toCity.get_location().x)

#获取城池评分（相邻城市中，自己的城越多，分越高；敌人的城越多，分越少）
func _get_city_score(cityId:int, vstateId:int):
	var city = clCity.city(cityId)
	var vid = city.get_vstate_id()
	if vid == -1:
		# 空城
		return 2000
	if vid != vstateId:
		# 盟友城池，尽量避开
		if 0 < clVState.get_alliance_month(vstateId, vid):
			return 0
	# 根据士兵数计算基础评分
	var score = -_get_soldiers_score(cityId);
	for connected in city.get_connected_city_ids():
		var connectedCity = clCity.city(connected)
		if connectedCity.get_vstate_id() == vstateId:
			# 被我方城池包围的目标，加分
			score += _get_soldiers_score(connected) / 3
	# 究极难度下，对玩家的仇恨值随机增加
	if DataManager.diffculities >= 3:
		var targetVstate = clVState.vstate(vid)
		if DataManager.get_actor_controlNo(targetVstate.get_lord_id()) >= 0:
			if Global.get_rate_result(20):
				score += 2000
	# 仇恨势力翻倍
	var vs = clVState.vstate(vstateId)
	if vs.hate(vid):
		score = score * 2
	# 考虑外交关系
	var idx = vs.get_relation_index(vid)
	score = int(score * (100.0 - idx) / 100.0)
	return score

#计算城池兵力评分
func _get_soldiers_score(cityId:int):
	var num = 0;
	var city = clCity.city(cityId)
	var i = 0;
	for actorId in city.get_actor_ids():
		var actor = ActorHelper.actor(actorId)
		num += actor.get_soldiers()/100;
		i+=1;
		if i>=5:
			break;
	return num;

#获取城池消耗（自己城消耗1，敌城武将越多，消耗越大）
func _get_city_cost(cityId:int, vstateId:int):
	var city = clCity.city(cityId)
	# 空城或自城
	if city.get_vstate_id() in [vstateId, -1]:
		return 1
	var cost = 1 + city.get_actors_count() * 10
	var targetVstateId = city.get_vstate_id()
	var vs = clVState.vstate(vstateId)
	#盟友城池，尽量避开
	if 0 < clVState.get_alliance_month(vstateId, targetVstateId):
		cost *= 10000
	if vs.hate(targetVstateId):
		cost = cost / 2
	if vs.love(targetVstateId):
		cost += 100
	return cost

#获取相邻的评分最高敌城攻击路线
func _get_next_target_route(vstateId:int)->Array:
	var targetCityIds = [];
	var max_score = -5000000;
	var checked = [] #已经检查过的城池
	var toCheck = clCity.all_city_ids()
	toCheck.shuffle()
	for id in toCheck:
		var city = clCity.city(id)
		if city.get_vstate_id() != vstateId:
			continue
		for nearEnemyCityId in city.get_connected_city_ids([], [vstateId]):
			if checked.has(nearEnemyCityId):
				continue
			checked.append(nearEnemyCityId)
			var score = max(0, _get_city_score(nearEnemyCityId, vstateId))
			if score > max_score:
				max_score = score
				targetCityIds = [[city.ID, nearEnemyCityId]]
			elif score == max_score:
				targetCityIds.append([city.ID, nearEnemyCityId])
	if targetCityIds.empty():
		return []
	targetCityIds.shuffle()
	var target = targetCityIds[0]
	var fromCityId = int(target[0])
	var targetCityId = int(target[1])
	return [fromCityId, targetCityId]
