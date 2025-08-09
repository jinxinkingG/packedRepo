extends "effect_20000.gd"

# 守业锁定技
#【守业】大战场,主将锁定技。若你为守方，你方武将每回合机动力恢复满值。

func on_trigger_20013() -> bool:
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled:
		return false
	var extra = wa.get_max_action_ap() - wa.action_point
	if extra <= 0:
		return false
	ske.change_actor_ap(wa.actorId, extra)
	ske.war_report()
	return false
