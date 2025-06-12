extends "effect_20000.gd"

#王佐锁定技
#【王佐】大战场,锁定技。我方大战场回合结束时，我方所有武将机动力+3

func on_trigger_20016()->bool:
	if me == null or me.disabled or not me.has_position():
		return false
	for targetId in get_teammate_targets(me, 999):
		ske.change_actor_ap(targetId, 3)
	ske.change_actor_ap(me.actorId, 3)
	ske.war_report()
	return false
