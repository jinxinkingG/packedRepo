extends "effect_20000.gd"

#困名锁定技
#【困名】大战场，锁定技。结束阶段，若你是己方机动力最高的武将，将机动力平均分给己方所有将领。

func on_trigger_20016()->bool:
	if me == null or me.disabled or not me.has_position():
		return false
	var targets = get_teammate_targets(me, 999)
	if targets.empty():
		return false
	var total = 0
	var teammates = []
	for targetId in targets:
		var wa = DataManager.get_war_actor(targetId)
		if wa.action_point > me.action_point:
			return false
		teammates.append(wa)
		total += wa.action_point
	total += me.action_point
	var ap = int(total / (targets.size() + 1))
	var shared = 0
	for wa in teammates:
		var diff = ap - wa.action_point
		if diff <= 0:
			continue
		shared += ske.change_actor_ap(wa.actorId, diff)
	if shared > 0:
		ske.change_actor_ap(me.actorId, -shared)
		ske.war_report()
	return false
