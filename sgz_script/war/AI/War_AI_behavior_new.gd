extends "War_AI_behavior.gd"

# 普通难度的 AI 行动逻辑

#行为模式
func behavior(wvId:int):
	var wf = DataManager.get_current_war_fight()
	#当前方
	var wv = wf.get_war_vstate(wvId);
	#己方主将
	var leader = wv.get_leader()
	#敌方军势
	var enemy:War_Vstate = wv.get_enemy_vstate()
	#敌人主将
	var enemyLeader = enemy.get_leader()
	#太守府位置
	var map = SceneManager.current_scene().war_map
	var mainCityPosition = map.get_position_by_buildCN("太守府")

	var actorId = DataManager.get_env_int(VAR_CUR_ACTOR)
	if actorId < 0:
		actorId = next_behavior_actor(wv)
		DataManager.set_env(VAR_CUR_ACTOR, actorId)
#	war_map.camer_to_actorId(actorId,"");#改变镜头位置
	var wa = wv.get_war_actor(actorId)
	if wa == null:
		actorId = next_behavior_actor(wv)
		DataManager.set_env(VAR_CUR_ACTOR, actorId)
		wa = wv.get_war_actor(actorId)
	if wa == null:
		return
	if wa.disabled or not wa.has_position():
		_end_action(wa)
		return

	# 行动前更新 AI
	wa.init_AI()
	DataManager.player_choose_actor = wa.actorId
	currentBehaviorActorId = wa.actorId
	if currentBehaviorActorId != lastBehaviorActorId:
		trace("== AI 行动角色切换为 #{0}{1}，更新地图信息".format([
			currentBehaviorActorId, ActorHelper.actor(wa.actorId).get_name()
		]))
		map.aStar.update_map_for_actor(wa)

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

	# 如果优先目标正好在身边（由技能设定），直接攻击
	if _try_prioritized_target(wa):
		return

	# 一.2. 检查主城，若主城无人且可达，无视 AI， 直奔主城
	if _check_for_main_city(wa):
		return

	# 一.3. 检查是不是需要买米
	if _check_for_go_riceshop(wa):
		return

	# 一.4. 检查是不是需要去治疗
	if _check_for_go_hospital(wa):
		return

	# 一.5. 有条件尝试用计
	if _try_scheme(wa):
		return

	# 一.6. 该撤就撤
	if _retreat(wa):
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
	trace("   #{0}{1} 行动 at <{4},{5}>, 机动力 {2} 策略：{3}".format([
		wa.actorId, wa.get_name(), wa.action_point, wa.AI,
		wa.position.x, wa.position.y
	]))
	match wa.AI:
		War_Character.AI_Enum.DefenceMain: #守主将
			if leader != null:
				# 获取离主将最近的敌人
				var target = leader.get_nearest_army()
				if target == null or target.disabled:
					_end_action(wa)
					return
				var distance = Global.get_distance(target.position, leader.position)
				if distance <= attackRange:
					if _chase_target_or_position(wa, target, target.position):
						return
				else:
					if _check_for_city_door(wa):
						return
		War_Character.AI_Enum.AttackMain: #扑主城 或扑主城
			# 如果机动力不足，且已经在城门位置，先不冲
			if wa.position in map.door_position \
				and wa.action_point < 7:
				trace("   #{0}{1} 扑主城暂停，城门 hold，剩余机动力 {2}".format([
					wa.actorId, ActorHelper.actor(wa.actorId).get_name(), wa.action_point
				]))
			else:
				var target = null
				if wa.side() == "防守方":
					target = enemyLeader
				if _chase_target_or_position(wa, target, mainCityPosition):
					return
				trace("   #{0}{1} 扑主城中断，剩余机动力 {2}".format([
					wa.actorId, ActorHelper.actor(wa.actorId).get_name(), wa.action_point
				]))
		War_Character.AI_Enum.AttackNear: #扑最近
			var target = wa.get_nearest_army()
			if target == null:
				_end_action(wa)
				return
			var distance = Global.get_distance(target.position, wa.position)
			if distance <= attackRange:
				if _chase_target_or_position(wa, target, target.position):
					return

	# 没有明确目标，判断周围
	if _secure_around(wa):
		return

	_end_action(wa)
	return


#AI移动
func _move(wa:War_Actor, new_position:Vector2, withStrategy:bool=true)->bool:
	if not wa.can_move():
		return false
	if(wa.position == new_position):
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
	var war_map = SceneManager.current_scene().war_map
	if war_map.require_camer_move(wa):
		war_map.camer_to_actorId(wa.actorId,"AI_move_0");
	else:
		FlowManager.add_flow("AI_move_0")
	return true


# 统计已经设定了指定 AI 的队友数
func _find_already_set(me:War_Actor, AIVal:int)->int:
	var ret:int = 0
	for wa in me.get_teammates(false):
		if wa.AI == AIVal:
			ret += 1
	return ret

# 检查是否已经在目标店铺，如果是，执行操作
# @return 是否成功操作
func _check_for_facilities_op(wa:War_Actor)->bool:
	var actor = ActorHelper.actor(wa.actorId)
	var wv = wa.war_vstate()
	var war_map = SceneManager.current_scene().war_map
	var buildCN = war_map.get_buildCN_by_position(wa.position)
	match buildCN:
		"医馆":
			if actor.is_injured() and wv.money >= 50:
				actor.set_hp(actor.get_max_hp()) # 好家伙
				wv.money -= 50
				return true
		"米屋":
			var amount = _can_buy_rice_numbers(wa.wvId)
			if amount > 0:
				var wf = DataManager.get_current_war_fight()
				var city = wf.target_city()
				var cost = int(amount * 100 / city.get_rice_buy_price())
				wv.money = max(0, wv.money - cost)
				wv.rice = min(9999, wv.rice + amount)
				return true
		"装备店":
			pass
	return false


# 检查是否需要去买米，如果需要，立刻行动
# @return true 表示行动完成，false 表示需要继续判断
func _check_for_go_riceshop(wa:War_Actor)->bool:
	var wv = wa.war_vstate()
	var war_map = SceneManager.current_scene().war_map
	var pos = war_map.get_position_by_buildCN("米屋")
	if _can_buy_rice_numbers(wa.wvId) <= 0 or pos.x < 0:
		# 米够用
		if wa.AI == War_Character.AI_Enum.GotoRiceshop:
			wa.init_AI()
		return false

	var alreadySet = _find_already_set(wa, War_Character.AI_Enum.GotoRiceshop)
	if alreadySet > 0:
		# 已经有别人去买了
		return false

	if wa.side() == "攻击方":
		# 攻击方非主将可以去，只有一人时也可以去
		if wv.main_actorId != wa.actorId or wv.get_actors_count() == 1:
			wa.AI = War_Character.AI_Enum.GotoRiceshop
	else:
		# 防守方，处于攻击状态的武将可以去
		if wa.AI in [War_Character.AI_Enum.AttackMain,War_Character.AI_Enum.AttackNear]:
			wa.AI = War_Character.AI_Enum.GotoRiceshop

	# 不准备去买米，返回继续执行其他判断
	if wa.AI != War_Character.AI_Enum.GotoRiceshop:
		return false

	# 准备去买米，立刻行动
	var distance = Global.get_distance(pos, wa.position)
	if distance == 1:
		# 已在米屋边
		if _move(wa, pos):
			return true
		# 无法进入米屋
		var who = DataManager.get_war_actor_by_position(pos)
		if who == null:
			_end_action(wa)
			return true
		if wa.is_enemy(who):
			# 被敌人占据，尝试攻击
			if _attack(wa, who.actorId):
				return true
			else:
				_end_action(wa)
				return true
		else:
			# 被队友占据
			_end_action(wa)
			return true

	# 距离还远，赶路
	var route = war_map.aStar.get_path(wa.position, pos)
	if route.size() > 1 and _move(wa, route[1]):
		return true
	return false

# 检查是否需要去治疗，如果需要，立刻行动
# @return true 表示行动完成，false 表示需要继续判断
func _check_for_go_hospital(wa:War_Actor)->bool:
	var actor = ActorHelper.actor(wa.actorId)
	var war_map = SceneManager.current_scene().war_map
	var pos = war_map.get_position_by_buildCN("医馆")
	var wv = wa.war_vstate()
	if actor.get_hp() * 3 > actor.get_max_hp() or pos.x < 0 or wv.money < 50:
		if wa.AI == War_Character.AI_Enum.GotoHospital:
			wa.init_AI()
		return false

	wa.AI = War_Character.AI_Enum.GotoHospital
	# 准备去治疗，立刻行动
	var distance = Global.get_distance(pos, wa.position)
	if distance == 1:
		# 已在医院边
		if _move(wa, pos):
			return true
		# 无法进入医院
		var who = DataManager.get_war_actor_by_position(pos)
		if who == null:
			return false
		elif wa.is_enemy(who):
			# 被敌人占据，尝试攻击
			if _attack(wa, who.actorId):
				return true
			else:
				_end_action(wa)
				return true
		else:
			# 被队友占据
			_end_action(wa)
			return true

	# 距离还远，赶路
	var route = war_map.aStar.get_path(wa.position, pos)
	if route.size() > 1 and _move(wa, route[1]):
		return true
	return false

# 检查是否直奔主城
# @return true 表示行动完成，false 表示需要继续判断
func _check_for_main_city(wa:War_Actor):
	var war_map = SceneManager.current_scene().war_map
	var pos = war_map.get_position_by_buildCN("太守府")
	if DataManager.get_war_actor_by_position(pos) == null:
		self.trace("== 主城无人，#{0} 的位置 <{1},{2}>，主城位置 <{3}, {4}>，机动力 {5}".format([
			wa.actorId, wa.position.x, wa.position.y, pos.x, pos.y, wa.action_point
		]))
		var route = war_map.aStar.get_clear_path(wa.position, pos)
		if route.size() > 1 and _move(wa, route[1], false):
			self.trace("   向主城移动，#{0} 的位置 <{1},{2}>，主城位置 <{3}, {4}>，机动力 {5}".format([
				wa.actorId, wa.position.x, wa.position.y, pos.x, pos.y, wa.action_point
			]))
			return true
	return false

# 检查是否对伪击转杀发动反击
# @return true 表示行动完成，false 表示需要继续判断
func _counter_attack(wa:War_Actor):
	if wa.side() != "防守方":
		return false
	if not wa.dic_other_variable.has("被用计策"):
		return false
	if not wa.dic_other_variable["被用计策"].has("伪击转杀"):
		return false

	# 对我用过伪击的将
	var hatedActorId = int(wa.dic_other_variable["被用计策"]["伪击转杀"])
	var hatedWarActor = DataManager.get_war_actor(hatedActorId)
	if not wa.is_enemy(hatedWarActor):
		#投降我方了？算了
		wa.dic_other_variable.erase("被用计策")
		return false
	if hatedWarActor == null or hatedWarActor.disabled:
		# 已经灭了，算了
		wa.dic_other_variable.erase("被用计策")
		return false

	var distance = Global.get_distance(hatedWarActor.position, wa.position)
	if distance == 1 and _attack(wa, hatedActorId):
		# 可以攻击，直接攻击
		return true

	if distance >= 3:
		# 已经跑远了，算了
		wa.AI = War_Character.AI_Enum.DefenceMain
		wa.dic_other_variable.erase("被用计策")
		return false

	# 没跑远，追
	var war_map = SceneManager.current_scene().war_map
	var route = war_map.aStar.get_path(wa.position, hatedWarActor.position)
	if route.size() > 1 and _move(wa, route[1]):
		return true

	return false

func _consider_scheme(wa:War_Actor)->bool:
	if wa.actor().get_wisdom() < 70:
		return false
	return true

# 尝试用计
# @return true 表示行动完成，false 表示需要继续判断
func _try_scheme(wa:War_Actor)->bool:
	if not _consider_scheme(wa):
		return false
	DataManager.clear_common_variable(["计策.ONCE"])
	var excludedActorIds = []
	SkillHelper.auto_trigger_skill(wa.actorId, 20026, "")
	# 先排除定止对象，加速判断
	for w in wa.get_enemy_war_actors(true):
		# 已经被定止的单位，如果定止回合是 1，排除
		if w.get_buff("定止")["回合数"] == 1:
			excludedActorIds.append(w.actorId)
			continue
		# 简化高势的实现，避免重复技能调用性能消耗过大
		# 这里与技能效果是重复的，但可以避免大量反复调用的消耗
		if SkillHelper.actor_has_skills(w.actorId, ["高势"]):
			var war_map = SceneManager.current_scene().war_map
			if war_map.get_blockCN_by_position(w.position) == "山地":
				excludedActorIds.append(w.actorId)

	# @since 1.574
	# 在判断计策目标时，可能会产生大量重复的技能获取
	# 因此，临时允许的技能列表获取 cache，以加速判断
	SkillHelper.reset_skills_list_cache(true)
	DataManager.game_trace("")
	var rateLimit = 30
	if _try_scheme_however(wa):
		rateLimit = 10
	var schemeCheckRes = was.best_use_strategy(wa.actorId, excludedActorIds, scheme_history, rateLimit)
	DataManager.game_trace("SCHEME_DECIDE<{0}>".format([wa.actorId]))
	SkillHelper.reset_skills_list_cache(false)
	var targetId = int(schemeCheckRes["目标"])
	if targetId < 0:
		DataManager.clear_common_variable(["计策.ONCE"])
		return false
	var actor = ActorHelper.actor(wa.actorId)
	var schemeInfo = StaticManager.get_stratagem(schemeCheckRes["计策名"])
	if not schemeInfo.performable(wa.actorId):
		DataManager.clear_common_variable(["计策.ONCE"])
		# 机动力不足以发动
		return false

	if _strategem(wa, targetId, schemeCheckRes["计策名"]):
		self.trace("   #{0}{1} 对 #{4}{5} 发动计策【{6}】, 机动力 {2} 策略：{3}".format([
			wa.actorId, ActorHelper.actor(wa.actorId).get_name(), wa.action_point, wa.AI,
			targetId, ActorHelper.actor(targetId).get_name()
		]))
		return true

	return false

# 尝试使用主动技
# @return true 表示行动完成，false 表示需要继续判断
func _try_active_skill(wa:War_Actor)->bool:
	for skill in SkillHelper.get_actor_active_skills(wa.actorId):
		for effect in SkillHelper.get_skill_effects(wa.actorId, skill, ["主动"]):
			var ske = effect.create_ske_for(wa.actorId)
			SkillHelper.save_skill_effectinfo(ske)
			var gd = Global.load_script(effect.path)
			gd._init()
			if not gd.check_AI_perform():
				continue
			LoadControl.load_script(effect.path)
			FlowManager.add_flow("effect_{0}_AI_start".format([effect.id]))
			return true
	return false

# 身边发现弱点，直接攻击
func _attack_weak_point(wa:War_Actor)->bool:
	if wa.action_point < 4:
		return false
	# 不明确合适的 score 阈值，暂不使用 best_attack_target
	for dir in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		var target = DataManager.get_war_actor_by_position(wa.position + dir)
		if target == null or target.disabled:
			continue
		if target.war_vstate().side == wa.war_vstate().side:
			continue
		wa.battle_init(true)
		target.battle_init(true)
		if wa.battle_morale - target.battle_morale >= 16 or target.battle_morale <= 25:
			return _attack(wa, target.actorId)
	return false

# 检查是否待机
# @return true 表示行动完成，false 表示需要继续判断
func _standing_still(wa:War_Actor)->bool:
	var wf = DataManager.get_current_war_fight()
	var wv = wa.war_vstate()
	if wa.side() == "攻击方":
		# 前 4 天，主将谨慎，粮草足够，有队友，不出击
		if wf.date <= 5 \
			and wa.actorId == wv.main_actorId \
			and wv.get_actors_count() > 1:
			self.trace("   #{0}{1} 因主将逻辑保持淡定，停留在 <{4},{5}>, 机动力 {2} 策略：{3}".format([
				wa.actorId, ActorHelper.actor(wa.actorId).get_name(), wa.action_point, wa.AI,
				wa.position.x, wa.position.y
			]))
			_end_action(wa)
			return true
		else:
			wa.AI = War_Character.AI_Enum.AttackMain
			return false
	# 防守方
	var war_map = SceneManager.current_scene().war_map
	var mainCityPosition = war_map.get_position_by_buildCN("太守府")
	if wa.AI == War_Character.AI_Enum.MainCity and wa.position == mainCityPosition:
		_end_action(wa)
		return true
	return false

# 追击指定目标
# @return true 表示行动完成，false 表示需要继续判断
func _chase_target_or_position(wa:War_Actor, target:War_Actor, position:Vector2)->bool:
	if target != null:
		if wa.is_enemy(target) and Global.get_distance(target.position, wa.position) == 1:
			# 敌人就在身边，直接攻击
			if _attack(wa, target.actorId):
				return true
		# 敌人不在身边，以其位置为目标
		position = target.position
	var war_map = SceneManager.current_scene().war_map
	var route = war_map.aStar.get_path(wa.position, position)
	if route.size() > 1 and _move(wa, route[1]):
		return true
	return false

func next_behavior_actor(wv:War_Vstate)->int:
	return next_behavior_actor_round_robin(wv)

# 从主将开始循环行动
func next_behavior_actor_round_robin(wv:War_Vstate)->int:
	lastBehaviorActorId = currentBehaviorActorId
	if currentBehaviorActorId < 0:
		return wv.main_actorId
	var found = false
	for wa in wv.get_war_actors(false, true):
		if found:
			return wa.actorId
			break
		if wa.actorId == lastBehaviorActorId:
			found = true
			continue
	return currentBehaviorActorId


# 决定攻击扫描范围
func _adjust_AI_and_attack_range(wa:War_Actor, riceEnough:bool):
	var wf = DataManager.get_current_war_fight()
	# 若米不足，无论攻守方，除了守城的和买米的，总攻
	if not riceEnough:
		if not wa.AI in [War_Character.AI_Enum.GotoRiceshop, War_Character.AI_Enum.MainCity]:
			wa.AI = War_Character.AI_Enum.AttackMain
			return 100
	# 攻方疯狗模式
	if wa.side() == "攻击方" and wf.date > 20:
		wa.AI = War_Character.AI_Enum.AttackMain
		return 100
	# 在城门的守将，行为改为守卫主将
	var war_map = SceneManager.current_scene().war_map
	if wa.side() == "防守方" and wa.position in war_map.door_position:
		wa.AI = War_Character.AI_Enum.DefenceMain
		return 2
	# 守卫者保守攻击
	if wa.AI == War_Character.AI_Enum.DefenceMain:
		return 5

	return 100

# 尝试抢城门
func _check_for_city_door(wa:War_Actor):
	var war_map = SceneManager.current_scene().war_map
	var pos = get_nearest_city_door(wa)
	if pos.x < 0 or pos.y < 0:
		return false
	if wa.position == pos:
		_end_action(wa)
		return true
	var who = DataManager.get_war_actor_by_position(pos)
	if who == null:
		# 最近的城门无人
		var route = war_map.aStar.get_clear_path(wa.position, pos)
		if route.size() > 1 and _move(wa, route[1], false):
			self.trace("   向城门移动，#{0} 的位置 <{1},{2}>，城门位置 <{3}, {4}>，机动力 {5}".format([
				wa.actorId, wa.position.x, wa.position.y, pos.x, pos.y, wa.action_point
			]))
			return true
	elif wa.is_enemy(who):
		# 最近的城门被敌人占据
		return _chase_target_or_position(wa, who, pos)
	else:
		# 最近的城门被队友占据
		var blockCN = war_map.get_blockCN_by_position(wa.position)
		if not blockCN in ["城墙"]:
			# 不在城墙上，转换 AI 为攻击最近
			wa.AI = War_Character.AI_Enum.AttackNear
		# TODO，考虑是否换防
	return false

func get_nearest_city_door(wa:War_Actor)->Vector2:
	var war_map = SceneManager.current_scene().war_map
	var minDistance = 999
	var ret:Vector2 = Vector2(-1, -1)
	for door in war_map.door_position:
		var disv = door - wa.position
		var distance = abs(disv.x) + abs(disv.y)
		if distance < minDistance:
			minDistance = distance
			ret = door
	return ret

# 检查身周单位并做出反应
func _secure_around(wa:War_Actor)->bool:
	var attackCheckRes:Dictionary = wab.best_attack_target(wa.actorId)
	var targetActorId = int(attackCheckRes["目标"])
	if targetActorId < 0:
		return false
	return _attack(wa, targetActorId)

# 是否糟糕的移动选择
func _bad_movement(wa:War_Actor, pos:Vector2)->bool:
	return false

# 尝试攻击优先目标
func _try_prioritized_target(wa:War_Actor)->bool:
	var key = "战争.AI.优先目标.{0}".format([wa.actorId])
	var targetId = DataManager.get_env_int(key)
	if targetId < 0:
		return false
	var target = DataManager.get_war_actor(targetId)
	if target == null or target.disabled or not target.has_position():
		return false
	if not wa.is_enemy(target):
		return false
	if Global.get_distance(target.position, wa.position) > 1:
		return false
	# 敌人就在身边，直接攻击
	return _attack(wa, target.actorId)
