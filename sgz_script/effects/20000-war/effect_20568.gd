extends "effect_20000.gd"

# 孤战效果
#【孤战】大战场，锁定技。若你是本方唯一在场的武将，你的机动力上限+5，且每回合机动力回满。

func on_trigger_20013() -> bool:
	if me.get_teammates(false, true).empty():
		ske.set_actor_extra_ap_limit(actorId, 5)
		var limit = me.get_max_action_ap()
		if me.action_point < limit:
			ske.change_actor_ap(actorId, limit - me.action_point)
	else:
		ske.set_actor_extra_ap_limit(actorId, 0)
	ske.war_report()
	return false
