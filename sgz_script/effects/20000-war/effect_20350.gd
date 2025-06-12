extends "effect_20000.gd"

#自负锁定技 #机动力
#【自负】大战场，锁定技。你兵力大于1000时，每日机动力恢复，额外+3；否则，额外-3

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	if ActorHelper.actor(ske.skill_actorId).get_soldiers() > 1000:
		ske.change_actor_ap(ske.skill_actorId, 3)
	else:
		ske.change_actor_ap(ske.skill_actorId, -3)
	ske.war_report()
	return false
