extends "effect_20000.gd"

#枕戈效果
#【枕戈】大战场，锁定技。你的机动力上限+X（X=装备提供的攻击力）

func on_trigger_20013():
	var x = int(actor.get_equip_attr_total("攻击力"))
	ske.set_actor_extra_ap_limit(actorId, x)
	ske.war_report()
	return false
