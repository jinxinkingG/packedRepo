extends "effect_20000.gd"

#寻机效果
#【寻机】大战场,锁定技。你的机动力上限+10，每回合恢复的机动力额外+2

func on_trigger_20013() -> bool:
	ske.change_actor_ap(actorId, 2)
	ske.set_actor_extra_ap_limit(actorId, 10)
	ske.war_report()
	return false
