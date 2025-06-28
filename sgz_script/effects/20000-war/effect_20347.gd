extends "effect_20000.gd"

#烈驹效果
#【烈驹】大战场，主将锁定技。你方所有武将，机动力上限+5

const EXTRA_AP_LIMIT = 5

func on_trigger_20013() -> bool:
	ske.set_actor_extra_ap_limit(ske.actorId, EXTRA_AP_LIMIT)
	ske.war_report()
	return false
