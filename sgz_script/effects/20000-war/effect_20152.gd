extends "effect_20000.gd"

#扛刀效果
#【扛刀】大战场,锁定技。回合初始，若你方主将在你六格内，则该回合：你机动力恢复-3，你方主将机动力恢复+3。

const COST_AP = 3

func on_trigger_20013():
	if me == null or me.disabled or not me.has_position():
		return false
	var leader = me.get_leader()
	if leader == null or leader.disabled or not leader.has_position():
		return false

	if Global.get_range_distance(leader.position, me.position) > 6:
		return false

	ske.change_actor_ap(actorId, -COST_AP)
	ske.change_actor_ap(leader.actorId, COST_AP)
	ske.war_report()
	return false
