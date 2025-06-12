extends "effect_20000.gd"

#先锋效果实现
#【先锋】大战场,锁定技。战争前3日，每回合初始，你的机动力+15

func on_trigger_20013()->bool:
	if me.disabled:
		return false
	var wf = DataManager.get_current_war_fight()
	if wf.date > 3:
		return false
	ske.change_actor_ap(me.actorId, 15)
	ske.war_report()
	return false
