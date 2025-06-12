extends "effect_20000.gd"

#结营效果
#【结营】大战场，主将锁定技。己方阵营，相连接的武将们，被用单目标的伤兵计时，伤害量减少2X/(10+X)。X=连接总人数

func on_trigger_20011() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(actorId) != ske.actorId:
		return false
	if se.stratagem.get_targeting_val("neighbourIncluded") == "1":
		return false
	if se.rangeRadius > 0:
		return false
	var damageTargetId = DataManager.get_env_int("计策.ONCE.伤害武将")
	var wa
	if damageTargetId == actorId:
		wa = me
	else:
		wa = DataManager.get_war_actor(damageTargetId)
		if not me.is_teammate(wa) or not wa.has_position():
			return false
	var checkings = [wa]
	var checked = []
	while not checkings.empty():
		var w = checkings.pop_front()
		if w.actorId in checked:
			continue
		checked.append(w.actorId)
		for dir in StaticManager.NEARBY_DIRECTIONS:
			var next = DataManager.get_war_actor_by_position(w.position + dir)
			if next == null or not me.is_teammate(next) and me.actorId != next.actorId:
				continue
			if next.actorId in checked:
				continue
			checkings.append(next)
	var x = checked.size()
	if x <= 1:
		return false
	x = int(200 * x / (10 + x))
	change_scheme_damage_rate(-x)
	return false
