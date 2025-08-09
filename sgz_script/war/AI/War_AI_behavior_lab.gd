extends "War_AI_behavior_new.gd"

# 挑战难度的 AI 行动逻辑
# 实验室版

# 1. 每天由主将根据战场形势判断当前行动
# 2. 增加适当的互动
# 3. 每个部队的行动，不再完全独立决策：
#    - 主将随时调度 @see next_behavior_actor
#    - 不再使用全局 VAR_END_ACTOR 分别标记
#    - 主将判断无人可调度时，全部加入 VAR_END_ACTOR 以配合主流程控制

var map

enum Strategy {
	# 默认策略
	DEFAULT = 0
	# 全民进攻
	ATTACK_PUSH = 1
}

class TacticTarget:
	var type:String
	var pos:Vector2

	func reset() -> void:
		type = ""
		pos = Vector2(-1, -1)
		return

	func to_str() -> String:
		return "{0}|{1}|{2}".format([
			type, pos.x, pos.y
		])

	func from_str(val:String) -> void:
		reset()
		var pieces = val.split("|")
		if pieces.size() < 3:
			return
		type = pieces[0]
		var x = Global.intval(pieces[1])
		var y = Global.intval(pieces[2])
		pos = Vector2(x, y)
		return

func _init():
	map = SceneManager.current_scene().war_map
	return

# 回合开始，根据当前战场局势，决定各部队行动
func turn_start() -> void:
	var wf = DataManager.get_current_war_fight()
	var wv = wf.current_war_vstate()
	var leader = wv.get_leader()
	if leader == null or leader.disabled:
		return

	# 所有人清空目标
	for wa in wv.get_war_actors(false, true):
		clear_tactic_target(wa)

	var strategy = wv.env.get_int("战略")
	if strategy < 0:
		strategy = decide_general_strategy(wv)
		wv.env.set_env("战略", strategy)
		match strategy:
			Strategy.ATTACK_PUSH:
				var msg = "优势在我，全军压上！".format([
					strategy
				])
				leader.attach_free_dialog(msg, 0)
	return

# 判断全局情况并做出战略决定
func decide_general_strategy(wv:War_Vstate) -> int:
	# 防守方暂时没有
	if wv.is_defender():
		return Strategy.DEFAULT
	# 援军暂时没有
	if wv.is_reinforcement():
		return Strategy.DEFAULT
	# 进攻方
	return decide_attack_strategy(wv)

# 攻方判断
func decide_attack_strategy(wv:War_Vstate) -> int:
	var wf = DataManager.get_current_war_fight()
	# 防守方武将
	var defenders = wf.defenderWV.get_war_actors(false, true)
	# 我方武将
	var attackers = wv.get_war_actors(false, true)
	var advantage = 0
	for wa in attackers:
		if wa.get_soldiers() >= 1000:
			advantage += 1
	for wa in defenders:
		if wa.get_soldiers() >= 1000:
			advantage -= 1

	if advantage > 2:
		# 我方优势明显
		for wa in attackers:
			wa.set_AI(War_Actor.AI_Enum.ATTACK_PUSH)
		wv.get_leader().set_AI(War_Actor.AI_Enum.LEADER_HOLD)
		return Strategy.ATTACK_PUSH

	# TODO
	return Strategy.DEFAULT

# 当前战术目标
func get_tactic_target(wa:War_Actor) -> TacticTarget:
	var tt = TacticTarget.new()
	tt.from_str(Global.strval(wa.get_tmp_variable("战术目标", "")))
	return tt

# 设定移动位置目标
func set_tactic_target_position(wa:War_Actor, pos:Vector2) -> void:
	if not map.is_valid_position(pos):
		return
	var tt = TacticTarget.new()
	tt.type = "pos"
	tt.pos = pos
	wa.set_tmp_variable("战术目标", tt.to_str())
	return 

# 制定战术目标
func decide_tactic_target(wa:War_Actor) -> void:
	var tt = get_tactic_target(wa)
	if tt.type != "":
		# 已经有目标了，忽略
		return
	# 默认情况下，目标为主城
	var mainCityLocation = map.get_position_by_buildCN("太守府")
	set_tactic_target_position(wa, mainCityLocation)
	# 补充根据当前的 AI 判断
	match wa.AI:
		War_Actor.AI_Enum.LEADER_HOLD:
			# 主将等待，在相对安全的情况下靠近主城
			var targetPosition = Vector2(-1, -1)
			var safeDistance = 8
			var disv = wa.position - mainCityLocation
			if abs(disv.x) > safeDistance:
				targetPosition = mainCityLocation
				if disv.x > 0:
					targetPosition.x = mainCityLocation.x - safeDistance
				else:
					targetPosition.x = mainCityLocation.x + safeDistance
			elif abs(disv.y) > safeDistance:
				targetPosition = mainCityLocation
				if disv.y > 0:
					targetPosition.x = mainCityLocation.y - safeDistance
				else:
					targetPosition.x = mainCityLocation.y + safeDistance
			set_tactic_target_position(wa, targetPosition)
	return

# 清除战术目标
func clear_tactic_target(wa:War_Actor) -> void:
	wa.set_tmp_variable("战术目标", null)
	return

# 选择下一个行动单位
func next_behavior_actor(wv:War_Vstate)->int:
	lastBehaviorActorId = currentBehaviorActorId
	if wv.is_attacker():
		return next_behavior_actor_attacker(wv)
	return next_behavior_actor_defender(wv)

# 防守方，从最聪明的开始
func next_behavior_actor_defender(wv:War_Vstate)->int:
	var wf = DataManager.get_current_war_fight()
	var endActors = DataManager.get_env_int_array(VAR_END_ACTOR)
	var maxWisdom = 1
	var ret = -1
	for wa in wv.get_war_actors(false, true):
		if wa.actorId in endActors:
			continue
		var wisdom = wa.actor().get_wisdom()
		if wisdom > maxWisdom:
			maxWisdom = wisdom
			ret = wa.actorId
	return ret

# 进攻方选择当前行动武将
func next_behavior_actor_attacker(wv:War_Vstate) -> int:
	var wf = DataManager.get_current_war_fight()
	var endActors = DataManager.get_env_int_array(VAR_END_ACTOR)
	var mainCityLocation = map.get_position_by_buildCN("太守府")
	var leader = wv.get_leader()

	var minScore = 999
	var chosen = -1
	for wa in wv.get_war_actors(false, true):
		# 已经待机的不考虑
		if wa.actorId in endActors:
			continue
		# 如果已经有路线计划，就直接赶路
		if not wa.get_AI_decided_route().empty():
			return wa.actorId
		# 首先确认战术目标
		decide_tactic_target(wa)
		# 计算与战术目标的距离
		var tt = get_tactic_target(wa)
		if tt.type == "":
			# 无效目标
			continue
		# 如果有人已经兵力不足，优选
		if wa.get_soldiers() < 200:
			return wa.actorId
		var score = Global.get_distance(tt.pos, wa.position)
		if score < minScore:
			chosen = wa.actorId
			minScore = score
	if chosen >= 0:
		# 距离目标最近的先行动
		return chosen
	# 没人可动，且主将未停止，则主将行动
	if leader == null or leader.disabled:
		return -1
	if leader.actorId in endActors:
		return -1
	return leader.actorId

func prepare_for_action(wa:War_Actor) -> void:
	currentBehaviorActorId = wa.actorId
	if currentBehaviorActorId != lastBehaviorActorId:
		trace("== AI 行动角色切换为 #{0}{1}，更新地图信息".format([
			currentBehaviorActorId, wa.get_name()
		]))
		map.aStar.update_map_for_actor(wa)

	map.update_ap()
	return

#行为模式
func behavior(wvId:int):
	#我方
	var wf = DataManager.get_current_war_fight()
	var wv = wf.get_war_vstate(wvId)

	# 总是动态决定下一个行动的人
	var actorId = next_behavior_actor(wv)
	DataManager.set_env(VAR_CUR_ACTOR, actorId)

	var wa = wv.get_war_actor(actorId)
	if wa == null or wa.disabled or not wa.has_position():
		stop_action(actorId)
		return

	DataManager.player_choose_actor = wa.actorId

	# 如果已有预定移动计划，直接移动
	if _try_scheduled_move(wa):
		return

	prepare_for_action(wa)

	var tt = get_tactic_target(wa)
	match tt.type:
		"pos": # 向指定目标移动
			if try_move_to_position(wa, tt.pos):
				return
	stop_action(wa.actorId)
	return

	## 阶段一，立即动作

	# 一.1. 如果已经在米屋医馆位置，处理买卖，无损机动力，反复执行直到无须操作
	while _check_for_facilities_op(wa):
		pass

	# 如果优先目标正好在身边（由技能设定），直接攻击
	if _try_prioritized_target(wa):
		return

	# 尝试发动主动技
	if _try_active_skill(wa):
		return

	# 再次，如果优先目标正好在身边（由技能设定），直接攻击
	if _try_prioritized_target(wa):
		return

	# 有条件尝试用计
	if _try_scheme(wa):
		return

	# 计策后，再次尝试发动主动技
	if _try_active_skill(wa):
		return

	# 继续已经计划好的移动路线
	if _try_scheduled_move(wa):
		return

	# 检查主城，若主城无人且可达，无视 AI， 直奔主城
	if _check_for_main_city(wa):
		return

	# 检查是不是需要买米
	if _check_for_go_riceshop(wa):
		return

	# 一.6. 该撤就撤
	if _retreat(wa):
		return

	# 一.4. 检查是不是需要去治疗
	if _check_for_go_hospital(wa):
		return

	# 一.7. 被伪击转杀总是尝试反击
	if _counter_attack(wa):
		return

	# 一.8. 如果发现弱点，直接攻击
	if _attack_weak_point(wa):
		return

	# 一.9. 该淡定要淡定
	if _standing_still(wa):
		return

	## 阶段二，综合判断目标调整行动模式

	# 估算米是否足够
	var riceEnough = wv.rice >= wv.get_actors_count() * 4 * 6
	# 调整 AI，并决定攻击扫描范围
	var attackRange:int = _adjust_AI_and_attack_range(wa, riceEnough)

	## 阶段三，目标调整结束，开始行动

	# 寻找敌军
	trace("#{0}{1} 行动 at <{4},{5}>, 机动力 {2} 策略：{3}".format([
		wa.actorId, wa.get_name(),
		wa.action_point, wa.get_AI_desc(),
		wa.position.x, wa.position.y
	]))
	match wa.AI:
		War_Character.AI_Enum.DefenceMain: #守主将
			if _strategy_defend_main(wa, attackRange):
				return
		War_Character.AI_Enum.AttackMain: #扑主城 或扑主城
			if _strategy_attack_main(wa):
				return
		War_Character.AI_Enum.AttackNear: #扑最近
			if _strategy_attack_near(wa, attackRange):
				return

	# 没有明确目标，判断周围
	if _secure_around(wa):
		return

	stop_action(wa.actorId)
	return

func try_move_to_position(wa:War_Actor, pos:Vector2) -> bool:
	var distance = Global.get_distance(pos, wa.position)
	if distance == 1:
		# 目标位置就在身边，不用寻路了
		if _move(wa, pos):
			return true
		# 无法移动
		var who = DataManager.get_war_actor_by_position(pos)
		if who == null:
			# 但目标位置又没有敌军存在，放弃移动
			return false
		if wa.is_enemy(who):
			# 敌人，尝试攻击
			return _attack(wa, who.actorId)
		# 有人阻挡，且是队友，放弃移动
		return false

	# 寻找可直接移动的路线
	var route = map.aStar.get_path_with_weight(wa.position, pos)
	if route.size() > 1:
		var positions = []
		var ap = 0
		for i in range(1, route.size()):
			ap += int(route[i][1])
			if ap > wa.action_point:
				break
			positions.append(route[i][0])
		if positions.empty():
			# 无法移动
			return false
		return _schedule_move(wa, positions)

	# 通向目标无路
	# 守方，待机
	if wa.is_defender():
		return false
	# 攻方，反复找接近且安全的路
	var retries = 0
	# 有限次尝试，避免没完没了
	while retries < 5:
		retries += 1
		route = map.aStar.get_assault_path_with_weight(wa.position, pos)
		if route.size() <= 1:
			trace("{0}未找到可接近目标的路".format([wa.get_name()]))
			return false
		var positions = []
		var ap = 0
		for i in range(1, route.size()):
			var p = route[i][0]
			if not wa.can_move_to_position(p):
				break
			ap += int(route[i][1])
			if ap > wa.action_point:
				break
			positions.append(p)
		if not positions.empty():
			# 确认最后的目标位置是否安全
			var lastPosition = positions[positions.size() - 1]
			if _cause_danger(wa, lastPosition):
				positions.pop_back()
		if positions.empty():
			# 无法移动
			trace("{0}找到接近的路径，但不可达".format([wa.get_name()]))
			break
			#map.aStar.set_position_disabled(lastPosition)
			#continue
		return _schedule_move(wa, positions)
	# 检查当前位置
	if not _cause_danger(wa, wa.position):
		trace("{0}多次尝试后仍未找到可接近目标的路线".format([wa.get_name()]))
		return false
	# 当前位置有风险，尝试规避
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var p = wa.position + dir
		if not _cause_danger(wa, p):
			if _move(wa, pos):
				trace("{0}向 <{1},{2}> 移动以规避风险".format([
					wa.get_name(), p.x, p.y,
				]))
				return true
	return false

# 检查是否待机
# @return true 表示行动完成，false 表示需要继续判断
func _standing_still(wa:War_Actor)->bool:
	# 无尽模式 0 兵别瞎打了
	if DataManager.endless_model and wa.get_soldiers() == 0:
		_end_action(wa)
		return true
	var wf = DataManager.get_current_war_fight()
	var war_map = SceneManager.current_scene().war_map
	var wv = wa.war_vstate()
	if wa.is_attacker():
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
		stop_action(wa.actorId)
		return true
	return false

# 是否糟糕的移动选择
func _bad_movement(wa:War_Actor, targetPos:Vector2)->bool:
	if not wa.is_attacker():
		return false

	var cost = DataManager.get_move_cost(wa.actorId, targetPos)
	if cost["机"] * 2 <= wa.action_point and cost["点"] * 2 <= wa.poker_point:
		# 还有足够的机动力与点数，暂不考虑
		return false

	# 可能是最后一步，考虑一下站位
	return _cause_danger(wa, targetPos)

# 若「我」处于目标位置，是否产生风险
func _cause_danger(wa:War_Actor, targetPos:Vector2)->bool:
	var danger = false
	for enemy in wa.get_enemy_war_actors(false):
		var a = enemy.actor()
		if a.get_wisdom() >= 98 and a.get_level() >= 6:
			danger = true
			break
		if a.get_suit().id == StaticManager.SUIT_ID_SHENGZHE:
			danger = true
			break
	if not danger:
		# 对面好像没人会劫火，怕啥？
		return false
	var terrian = map.get_blockCN_by_position(targetPos)
	if terrian in ["城门", "太守府"]:
		return false
	var score = 1
	# 假设自己移动到目标位置
	var connectedActors = {targetPos:wa.actorId}
	# 检查所有连接位置
	var positions = StaticManager.NEARBY_DIRECTIONS.duplicate(true)
	for i in positions.size():
		positions[i] = targetPos + positions[i]
	while not positions.empty():
		var pos = positions.pop_front()
		terrian = map.get_blockCN_by_position(pos)
		if terrian in ["城门", "太守府"]:
			continue
		var sibling = DataManager.get_war_actor_by_position(pos)
		connectedActors[pos] = -1
		if sibling == null or sibling.disabled or sibling.actorId == wa.actorId:
			continue
		if wa.is_enemy(sibling):
			# 是敌军，且与目标位置相邻，值得冒险
			if Global.get_distance(sibling.position, targetPos) == 1:
				score -= 2
			continue
		# 是友军
		connectedActors[pos] = sibling.actorId
		score += 1
		for dir in StaticManager.NEARBY_DIRECTIONS:
			var newPos = pos + dir
			if connectedActors.has(newPos):
				continue
			positions.append(newPos)
	DataManager.game_trace("{0}考虑移动到{1}，风险评分{2}".format([
		wa.get_name(), targetPos, score,
	]))
	return score >= 3

# 检查身周单位并做出反应
func _secure_around(wa:War_Actor)->bool:
	if scheme_history.has(str(wa.actorId)):
		# 简单判断，如果曾经用计，就不主动攻击
		# 如果进攻方堵住了城门，尝试让开道路
		if wa.side() == "进攻方":
			var blocking = false
			var vacants = []
			for dir in StaticManager.NEARBY_DIRECTIONS:
				var pos = wa.position + dir
				var sibling = DataManager.get_war_actor_by_position(pos)
				if sibling == null or sibling.disabled:
					vacants.append(pos)
				elif not blocking and wa.is_enemy(sibling):
					var terrian = map.get_blockCN_by_position(pos)
					blocking = terrian == "城门"
			# 尝试让开道路
			for pos in vacants:
				if _move(wa, pos):
					stop_action(wa.actorId)
					return false
		return false
	var attackCheckRes:Dictionary = wab.best_attack_target(wa.actorId)
	var targetActorId = int(attackCheckRes["目标"])
	if targetActorId < 0:
		return false
	return _attack(wa, targetActorId)

# 检查是否直奔主城
# @return true 表示行动完成，false 表示需要继续判断
func _check_for_main_city(wa:War_Actor):
	var pos = map.get_position_by_buildCN("太守府")
	if DataManager.get_war_actor_by_position(pos) != null:
		return false
	# 太守府无人
	var route = map.aStar.get_clear_path_with_weight(wa.position, pos)
	if route.size() < 1:
		# 主城不可达
		return false
	# 计算移动所需总机动力
	var total = 0
	var positions = []
	for i in range(1, route.size()):
		total += route[i][1]
		positions.append(route[i][0])
	if total > wa.action_point:
		# 机动力不足以直接占领主城
		return false
	# 机动力和路径都可直达，设定计划路线
	return _schedule_move(wa, positions)

# 设定计划好的路线，要求按计划移动
func _schedule_move(wa:War_Actor, route:PoolVector2Array)->bool:
	if route.empty():
		wa.set_AI_decided_route([])
		trace("{0}取消计划路线，停留在 <{1},{2}>".format([
			wa.get_name(), wa.position.x, wa.position.y,
		]))
		map.show_color_block_by_position([])
		return false
	map.show_color_block_by_position(route)
	var routeInfo = wa.set_AI_decided_route(route)
	trace("{0}已设定计划路线：{1}({2}...)".format([wa.get_name(), routeInfo.size(), routeInfo[0]]))
	# 马上开始行动
	return _try_scheduled_move(wa)

# 按既定的计划路线移动
func _try_scheduled_move(wa:War_Actor)->bool:
	var pos = wa.pop_AI_decided_route()
	if pos == Vector2(-1, -1):
		return false
	trace("{0}准备按设定路线，行动到 <{1}, {2}>，机动力 {3}".format([
		wa.get_name(), pos.x, pos.y, wa.action_point,
	]))
	if Global.get_distance(pos, wa.position) != 1:
		# 路径错误，取消计划
		return _schedule_move(wa, [])
	if not _move(wa, pos):
		# 无法移动到指定位置，取消计划
		return _schedule_move(wa, [])
	return true

# 挑战难度下，平衡计策和肌肉
func _consider_scheme(wa:War_Actor)->bool:
	if wa.is_attacker():
		# 攻击方
		if wa.action_point < 8 or wa.actor().get_wisdom() < 65:
			return false
		if wa.actor().get_power() >= wa.actor().get_wisdom() + 10:
			return false
		return true
	# 防守方
	if wa.actor().get_wisdom() < 60:
		return false
	return true

# 检查是否需要去买米，如果需要，立刻行动
# @return true 表示行动完成，false 表示需要继续判断
func _check_for_go_riceshop(wa:War_Actor)->bool:
	var wv = wa.war_vstate()
	var pos = map.get_position_by_buildCN("米屋")
	if pos.x < 0:
		# 没有米屋
		return false
	if _can_buy_rice_numbers(wa.wvId) <= 0:
		# 米够用
		if wa.AI == War_Character.AI_Enum.GotoRiceshop:
			wa.init_AI()
		return false

	if wa.AI != War_Character.AI_Enum.GotoRiceshop:
		var alreadySet = _find_already_set(wa, War_Character.AI_Enum.GotoRiceshop)
		if alreadySet > 0:
			# 已经有别人去买了
			return false

		var minDistance = Global.get_distance(pos, wa.position)
		var actioner = wa
		if wa.is_attacker():
			# 攻击方，非主将可以去，只有一人时也可以去
			for w in wa.get_teammates(false, true):
				if wv.main_actorId == wa.actorId and wv.get_actors_count() > 1:
					continue
		else:
			# 防守方，处于攻击状态的武将可以去
			for w in wa.get_teammates(false, true):
				if w.AI in [War_Character.AI_Enum.AttackMain, War_Character.AI_Enum.AttackNear]:
					continue
				var distance = Global.get_distance(pos, w.position)
				if distance < minDistance:
					minDistance = distance
					actioner = w

		actioner.AI = War_Character.AI_Enum.GotoRiceshop
		DataManager.game_trace("AI 米不足，决定由{0}去买米".format([actioner.get_name()]))

	# 不准备去买米，返回继续执行其他判断
	if wa.AI != War_Character.AI_Enum.GotoRiceshop:
		return false

	DataManager.game_trace("{0}在买米的路上".format([wa.get_name()]))
	# 准备去买米，立刻行动
	var distance = Global.get_distance(pos, wa.position)
	if distance == 1:
		# 已在米屋边
		if _move(wa, pos):
			return true
		# 无法进入米屋
		var who = DataManager.get_war_actor_by_position(pos)
		if who == null:
			# 无人占据，可能是被禁足或机动力不足等原因，终止行动
			stop_action(wa.actorId)
			return true
		if not wa.is_enemy(who):
			# 被队友占据，终止行动
			stop_action(wa.actorId)
			return true
		else:
			# 尝试攻击
			if _attack(wa, who.actorId):
				return true
			else:
				# 无法攻击，终止行动
				stop_action(wa.actorId)
				return true

	# 距离还远，赶路
	var route = map.aStar.get_path(wa.position, pos)
	if route.size() <= 1:
		# 无法前往
		# TODO，这里应该交给别人处理
		return false
	# 设定计划路线
	var positions = []
	positions.append_array(route)
	positions.pop_front()
	return _schedule_move(wa, positions)

# 检查是否需要去治疗，如果需要，立刻行动
# @return true 表示行动完成，false 表示需要继续判断
func _check_for_go_hospital(wa:War_Actor)->bool:
	var wv = wa.war_vstate()
	var pos = map.get_position_by_buildCN("医馆")
	if pos.x < 0:
		# 没有医馆
		return false
	var actor = wa.actor()
	if actor.get_hp() * 3 > actor.get_max_hp() or wv.money < 50:
		if wa.AI == War_Character.AI_Enum.GotoHospital:
			wa.init_AI()
		return false

	wa.AI = War_Character.AI_Enum.GotoHospital
	# 准备去治疗，立刻行动
	var disv = pos - wa.position
	var distance = abs(disv.x) + abs(disv.y)
	if distance == 1:
		# 已在医院边
		if _move(wa, pos):
			return true
		# 无法进入医院
		var who = DataManager.get_war_actor_by_position(pos)
		if who == null:
			return false
		elif not wa.is_enemy(who):
			# 被队友占据
			stop_action(wa.actorId)
			return true
		else:
			# 尝试攻击
			if _attack(wa, who.actorId):
				return true
			else:
				stop_action(wa.actorId)
				return true

	# 距离还远，赶路
	var route = map.aStar.get_path(wa.position, pos)
	if route.size() < 1:
		wa.init_AI()
		return false
	var positions = []
	positions.append_array(route)
	positions.pop_front()
	return _schedule_move(wa, positions)

# 追击指定目标
# @return true 表示行动完成，false 表示需要继续判断
func _chase_target_or_position(wa:War_Actor, target:War_Actor, position:Vector2)->bool:
	if target != null:
		if wa.is_enemy(target) and Global.get_distance(target.position, wa.position) == 1:
			# 敌人就在身边，直接攻击
			return _attack(wa, target.actorId)
		# 敌人不在身边，以其位置为目标
		position = target.position
	var distance = Global.get_distance(position, wa.position)
	if distance == 1:
		# 目标位置就在身边，不用寻路了
		if _move(wa, position):
			return true
		var who = DataManager.get_war_actor_by_position(position)
		if who == null:
			# 没有阻挡但无法移动？
			return false
		if wa.is_enemy(who):
			# 敌人，尝试攻击
			return _attack(wa, who.actorId)
		# 无计可施？
		return false
	# 直通目标
	var route = map.aStar.get_path_with_weight(wa.position, position)
	if route.size() > 1:
		var positions = []
		var ap = 0
		for i in range(1, route.size()):
			ap += int(route[i][1])
			if ap > wa.action_point:
				break
			positions.append(route[i][0])
		if positions.empty():
			# 无法移动
			return false
		return _schedule_move(wa, positions)
	# 通向目标无路
	# 守方，待机
	if wa.is_defender():
		return false
	# 攻方，反复找接近且安全的路
	var retries = 0
	# 有限次尝试，避免没完没了
	while retries < 5:
		retries += 1
		route = map.aStar.get_assault_path_with_weight(wa.position, position)
		if route.size() <= 1:
			trace("{0}未找到可接近目标的路".format([wa.get_name()]))
			return false
		var positions = []
		var ap = 0
		for i in range(1, route.size()):
			var pos = route[i][0]
			if not wa.can_move_to_position(pos):
				break
			ap += int(route[i][1])
			if ap > wa.action_point:
				break
			positions.append(pos)
		if not positions.empty():
			# 确认最后的目标位置是否安全
			var lastPosition = positions[positions.size() - 1]
			if _cause_danger(wa, lastPosition):
				positions.pop_back()
		if positions.empty():
			# 无法移动
			trace("{0}找到接近的路径，但不可达".format([wa.get_name()]))
			break
			#map.aStar.set_position_disabled(lastPosition)
			#continue
		return _schedule_move(wa, positions)
	# 检查当前位置
	if not _cause_danger(wa, wa.position):
		trace("{0}多次尝试后仍未找到可接近目标的路线".format([wa.get_name()]))
		return false
	# 当前位置有风险，尝试规避
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = wa.position + dir
		if not _cause_danger(wa, pos):
			if _move(wa, pos):
				trace("{0}向 <{1},{2}> 移动以规避风险".format([
					wa.get_name(), pos.x, pos.y,
				]))
				return true
	return false

# 结束行动回合
func stop_action(actorId:int)->void:
	var endActors = DataManager.get_env_int_array(VAR_END_ACTOR)
	endActors.append(actorId)
	DataManager.set_env(VAR_END_ACTOR, endActors)
	trace("{0}终止行动".format([actorId]))
	# 立刻更新机动力显示
	map.update_ap()
	FlowManager.add_flow("AI_before_ready")
	return

# 获取主要目标对象
func _get_main_target(wa:War_Actor)->War_Actor:
	if wa.is_defender():
		return wa.get_war_enemy_leader()
	# 进攻方只看位置，不看人
	return null

# 获取主要目标位置
func _get_main_target_position(wa:War_Actor)->Vector2:
	var mainCityPosition = map.get_position_by_buildCN("太守府")
	if map.aStar.get_attack_path(wa.position, mainCityPosition).size() > 0:
		# 主城有可攻击路线
		return mainCityPosition
	# 是否有锚定的城门
	var val = Global.strval(wa.get_ext_variable("AI.锚定城门")).split("|")
	if val.size() == 2:
		# 以锚定城门为目标
		return Vector2(int(val[0]), int(val[1]))
	# 还没有选定城门，选一个
	var minDistance = 99999
	var targetPosition = null
	for pos in map.inner_door_positions:
		# 有通畅的路径
		var route = map.aStar.get_clear_path_with_weight(wa.position, pos)
		if route.size() <= 1:
			continue
		var ap = 0
		for i in range(1, route.size()):
			ap += int(route[i][1])
		if ap < minDistance:
			minDistance = ap
			targetPosition = pos
	if targetPosition != null:
		wa.set_ext_variable("AI.锚定城门", "{0}|{1}".format([targetPosition.x, targetPosition.y]))
		trace("{0}选择直突城门 <{1},{2}>".format([
			wa.get_name(), targetPosition.x, targetPosition.y,
		]))
		return targetPosition
	for pos in map.inner_door_positions:
		var route = map.aStar.get_assault_path_with_weight(wa.position, pos)
		if route.size() <= 1:
			# 连攻击路径都没有，放弃这个选项
			continue
		var ap = 0
		for i in range(1, route.size()):
			ap += int(route[i][1])
		if ap < minDistance:
			minDistance = ap
			targetPosition = pos
	if targetPosition == null:
		# 没有城门目标，暂时以主城为目标，下次再找
		return mainCityPosition
	# 设定锚定城门并以之为目标
	wa.set_ext_variable("AI.锚定城门", "{0}|{1}".format([targetPosition.x, targetPosition.y]))
	trace("{0}尝试推进城门 <{1},{2}>".format([
		wa.get_name(), targetPosition.x, targetPosition.y,
	]))
	return targetPosition

func _strategy_defend_main(wa:War_Actor, attackRange:int)->bool:
	var leader = wa.get_leader()
	if leader == null:
		return false
	# 获取离主将最近的敌人
	var target = leader.get_nearest_army()
	if target == null or target.disabled:
		stop_action(wa.actorId)
		return true
	var distance = Global.get_distance(target.position, leader.position)
	if distance <= attackRange:
		if _chase_target_or_position(wa, target, target.position):
			return true
	else:
		if _check_for_city_door(wa):
			return true
	return false

func _strategy_attack_main(wa:War_Actor)->bool:
	var target = _get_main_target(wa)
	var targetPosition = _get_main_target_position(wa)
	if _chase_target_or_position(wa, target, targetPosition):
		return true
	trace("   #{0}{1} 扑主将中断，剩余机动力 {2}".format([
		wa.actorId, wa.get_name(), wa.action_point
	]))
	return false

func _strategy_attack_near(wa:War_Actor, attackRange:int)->bool:
	var target = wa.get_nearest_army()
	if target == null:
		stop_action(wa.actorId)
		return true
	var distance = Global.get_distance(target.position, wa.position)
	if distance <= attackRange:
		trace("{0}找到最近目标 {1} <{2},{3}>".format([
			wa.get_name(), target.get_name(),
			target.position.x, target.position.y,
		]))
		if _chase_target_or_position(wa, target, target.position):
			return true
	# 最近的敌人在范围之外，先冲主将
	return _strategy_attack_main(wa)

# 决定攻击扫描范围
func _adjust_AI_and_attack_range(wa:War_Actor, riceEnough:bool):
	var wf = DataManager.get_current_war_fight()
	# 若米不足，无论攻守方，除了守城的和买米的，总攻
	if not riceEnough:
		if not wa.AI in [War_Character.AI_Enum.GotoRiceshop, War_Character.AI_Enum.MainCity]:
			wa.AI = War_Character.AI_Enum.AttackMain
			return 100
	# 攻方疯狗模式
	if wa.is_attacker() and wf.date > 20:
		wa.AI = War_Character.AI_Enum.AttackMain
		return 100
	# 在城门的守将，行为改为守主城或守卫主将
	var war_map = SceneManager.current_scene().war_map
	if wa.is_defender() and wa.position in war_map.door_position:
		if wa.AI == War_Character.AI_Enum.MainCity:
			return 2
		wa.AI = War_Character.AI_Enum.DefenceMain
		return 2
	# 守卫者保守攻击
	if wa.AI == War_Character.AI_Enum.DefenceMain:
		return 5
	return 5

#AI移动
func _move(wa:War_Actor, new_position:Vector2, withStrategy:bool=true)->bool:
	if not wa.can_move():
		return false
	if wa.position == new_position:
		return false
	if not wa.can_move_to_position(new_position):
		return false
	# 计算移动消耗
	var cost = DataManager.get_move_cost(wa.actorId, new_position)
	if cost["机"] > wa.action_point or cost["点"] > wa.poker_point:
		self.trace("   #{0}{1} 不能移动到 <{2},{3}>，机动力/点数({4}/{5}:{6}/{7})不足".format([
			wa.actorId, ActorHelper.actor(wa.actorId).get_name(), new_position.x, new_position.y,
			wa.action_point, wa.poker_point, cost["机"], cost["点"]
		]))
		return false

	if withStrategy and self._bad_movement(wa, new_position):
		return false

	self.trace("   #{0}{1} 准备移动到 <{2},{3}>".format([
		wa.actorId, ActorHelper.actor(wa.actorId).get_name(), new_position.x, new_position.y
	]))
	DataManager.set_env("当前坐标", {
		"x": wa.position.x,
		"y": wa.position.y
	})
	DataManager.set_env("目标坐标", {
		"x": new_position.x,
		"y": new_position.y
	})
	var val = Global.strval(wa.get_ext_variable("AI.锚定城门")).split("|")
	if val.size() == 2:
		var doorPosition = Vector2(int(val[0]), int(val[1]))
		if doorPosition == new_position:
			var mainCityPosition = map.get_position_by_buildCN("太守府")
			# 已经占据了目标城门，改为太守府
			wa.set_ext_variable("AI.锚定城门", "{0}|{1}".format([mainCityPosition.x, mainCityPosition.y]))
			trace("{0}选择直突太守府 <{1},{2}>".format([
				wa.get_name(), mainCityPosition.x, mainCityPosition.y,
			]))
	if map.require_camer_move(wa):
		map.camer_to_actorId(wa.actorId, "AI_move_0")
	else:
		FlowManager.add_flow("AI_move_0")
	return true

# 身边发现弱点，直接攻击
func _attack_weak_point(wa:War_Actor)->bool:
	if wa.war_vstate().delegated > 0:
		if wa.is_defender():
			# 托管模式，守方不主动攻击弱点
			return false
	# 不具体计算所需机动力了，估算一下
	if wa.action_point < 4:
		return false
	var terrian = map.get_blockCN_by_position(wa.position)
	wa.battle_init(true)
	if wa.battle_morale < 32:
		return false
	var bestTarget = null
	var maxScore = -99999
	for target in wa.get_enemy_war_actors(true):
		var disv = target.position - wa.position
		var distance = abs(disv.x) + abs(disv.y)
		if distance > 2:
			continue
		if wa.is_defender() and distance > 1:
			if terrian in ["城门", "太守府"]:
				continue
		# 不具体计算所需机动力了，估算一下
		if distance == 2 and wa.action_point < 8:
			continue
		target.battle_init(true)
		var score = wa.battle_morale - target.battle_morale
		if score < 10:
			continue
		# 较强的不攻击
		if target.battle_morale >= 30:
			if wa.get_soldiers() < target.get_soldiers() + 500:
				continue
		score = score * 10 - distance * 80
		if score > maxScore:
			maxScore = score
			bestTarget = target
	if bestTarget == null:
		return false

	return _chase_target_or_position(wa, bestTarget, bestTarget.position)
