extends "effect_20000.gd"

#卫士被动效果
#【卫士】大战场,锁定技。若你不是主将：你无法使用计策，主将周围一格范围视为禁卫区，你移动到区域内，或攻击区域内的敌军，都不消耗机动力。同时，你在禁卫区内，不会成为计策目标。

func on_trigger_20007()->bool:
	# 计算移动机动力消耗时
	var targetInfo = DataManager.get_env_dict("行军目标")
	if not "x" in targetInfo or not "y" in targetInfo:
		return false
	var targetPosition = Vector2(int(targetInfo["x"]), int(targetInfo["y"]))
	var leader = check_zone(targetPosition)
	if leader == null:
		return false
	if Global.get_range_distance(targetPosition, leader.position) > 1:
		return false
	set_max_move_ap_cost([], 0)
	return false

func on_trigger_20014()->bool:
	# 计算攻击机动力时
	var costInfo = DataManager.get_env_dict("战争.攻击消耗")
	var targetId = Global.intval(costInfo["攻击目标"])
	var targetWA = DataManager.get_war_actor(targetId)
	if targetWA == null or targetWA.disabled:
		return false
	var leader = check_zone(targetWA.position)
	if leader == null:
		return false
	costInfo["固定"] = 0
	DataManager.set_env("战争.攻击消耗", costInfo)
	return false

func on_trigger_20024()->bool:
	# 检查是否可用计策
	if me.get_main_actor_id() == me.actorId:
		# 主将不生效
		return false
	var key = "战争.计策.允许.{0}".format([actorId])
	if DataManager.get_env_int(key) != 1:
		return false
	var msg = "【{0}】禁用计策".format([ske.skill_name])
	DataManager.set_env(key, msg)
	return false

func check_zone(pos:Vector2)->War_Actor:
	if me.get_main_actor_id() == me.actorId:
		# 主将不生效
		return null
	var leader = DataManager.get_war_actor(me.get_main_actor_id())
	if leader == null:
		return null
	if not me.has_position() or not leader.has_position():
		return null
	if Global.get_range_distance(pos, leader.position) > 1:
		return null
	return leader
