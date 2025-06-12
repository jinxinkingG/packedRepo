extends "War_AI_behavior_new.gd"

# 究极难度的 AI 行动逻辑
# 继承自普通难度，修改的部分重载实现

# 检查是否待机
# @return true 表示行动完成，false 表示需要继续判断
func _standing_still(wa:War_Actor)->bool:
	var wf = DataManager.get_current_war_fight()
	var war_map = SceneManager.current_scene().war_map
	var wv = wa.war_vstate()
	if wa.side() == "攻击方":
		if wa.actorId == wv.main_actorId:
			# 攻方主将，且有队友
			if wv.get_actors_count() > 1:
				# 前八天，且战损不大
				if wf.date < 8 and wv.get_all_soldiers() * 2 / 3 > wv.get_lose_sodiers():
					_end_action(wa)
					return true
			wa.AI = War_Character.AI_Enum.AttackMain
			return false
		return false
	# 防守方
	var mainCityPosition = war_map.get_position_by_buildCN("太守府")
	if wa.AI == War_Character.AI_Enum.MainCity and wa.position == mainCityPosition:
		_end_action(wa)
		return true
	return false

# 从离主城最近的单位开始行动
func next_behavior_actor(wv:War_Vstate)->int:
	var war_map = SceneManager.current_scene().war_map
	lastBehaviorActorId = currentBehaviorActorId
	if lastBehaviorActorId == -1:
		var nearest = -1
		var minDistance = 999
		var mainCityLocation = war_map.get_position_by_buildCN("太守府")
		for wa in wv.get_war_actors(false, true):
			if wa.actorId == lastBehaviorActorId:
				continue
			var disv = wa.position - mainCityLocation
			var distance = abs(disv.x) + abs(disv.y)
			if distance < minDistance:
				minDistance = distance
				nearest = wa.actorId
		return nearest
	else:
		return next_behavior_actor_round_robin(wv)

# 是否糟糕的移动选择
func _bad_movement(wa:War_Actor, targetPos:Vector2)->bool:
	if wa.side() != "攻击方":
		return false

	var cost = DataManager.get_move_cost(wa.actorId, targetPos)
	if cost["机"] * 2 <= wa.action_point and cost["点"] * 2 <= wa.poker_point:
		# 还有足够的机动力与点数，暂不考虑
		return false

	# 可能是最后一步，考虑一下站位
	var score = 1
	# 假设自己移动到目标位置
	var connectedActors = {targetPos:wa.actorId}
	# 检查所有连接位置
	var positions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	for i in positions.size():
		positions[i] = targetPos + positions[i]
	while not positions.empty():
		var pos = positions.pop_front()
		var _wa = DataManager.get_war_actor_by_position(pos)
		connectedActors[pos] = -1
		if _wa == null or _wa.disabled or _wa.actorId == wa.actorId:
			continue
		if wa.is_enemy(_wa):
			# 是敌军
			if Global.get_distance(wa.position, _wa.position) == 1:
				score -= 2
				continue
		# 是友军
		connectedActors[pos] = _wa.actorId
		score += 1
		for dir in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
			var newPos = pos + dir
			if connectedActors.has(newPos):
				continue
			positions.append(newPos)
	return score >= 3

# 检查身周单位并做出反应
func _secure_around(wa:War_Actor)->bool:
	if self.scheme_history.has(str(wa.actorId)):
		# 简单判断，如果曾经用计，就不主动攻击
		return false
	var attackCheckRes:Dictionary = wab.best_attack_target(wa.actorId)
	var targetActorId = int(attackCheckRes["目标"])
	if targetActorId < 0:
		return false
	return _attack(wa, targetActorId)

# 检查是否直奔主城
# @return true 表示行动完成，false 表示需要继续判断
func _check_for_main_city(wa:War_Actor):
	var war_map = SceneManager.current_scene().war_map
	var pos = war_map.get_position_by_buildCN("太守府")
	if DataManager.get_war_actor_by_position(pos) == null:
		var route = war_map.aStar.get_clear_path_with_weight(wa.position, pos)
		if route.size() < 1:
			# 主城不可达
			self.trace("== 主城无人，#{0} 的位置 <{1},{2}>，主城位置 <{3}, {4}>，没有路径".format([
				wa.actorId, wa.position.x, wa.position.y, pos.x, pos.y, wa.action_point,
			]))
			return false
		# 计算移动所需总机动力
		var total = 0
		for i in range(1, route.size()):
			total += route[i][1]
		if total > wa.action_point:
			self.trace("== 主城无人，#{0} 的位置 <{1},{2}>，机动力{5}不足，需{6}".format([
				wa.actorId, wa.position.x, wa.position.y, pos.x, pos.y, wa.action_point, total,
			]))
			return false
		self.trace("   尝试向主城移动，#{0} 的位置 <{1},{2}>，主城位置 <{3}, {4}>，机动力 {5}，需{6}".format([
			wa.actorId, wa.position.x, wa.position.y, pos.x, pos.y, wa.action_point, total,
		]))
		return _move(wa, route[1][0], false)
	return false

# 究极难度下，考虑更多肌肉
func _consider_scheme(wa:War_Actor)->bool:
	if wa.action_point < 8 or wa.actor().get_wisdom() < 70:
		return false
	if wa.actor().get_power() >= wa.actor().get_wisdom() + 10:
		if wa.side() == "攻击方":
			return false
	return true


