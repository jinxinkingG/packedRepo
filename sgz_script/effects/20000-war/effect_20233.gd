extends "effect_20000.gd"

#高势锁定技 #施加状态
#【高势】大战场,锁定技。结束阶段时若你处于山地地形，附加1回合的“围困”状态。你在山地时，无法成为对方计策目标。

func on_trigger_20016()->bool:
	if me.get_buff_label_turn(["围困"]) > 0:
		return false
	ske.set_war_buff(me.actorId, "围困", 2)
	ske.war_report()
	var msg = "传令下去，凭山固守"
	me.attach_free_dialog(msg)
	return false
