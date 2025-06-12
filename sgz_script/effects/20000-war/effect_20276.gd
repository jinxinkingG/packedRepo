extends "effect_20000.gd"

#不挠锁定技
#【不挠】大战场，锁定技。本回合被附加负面状态，下回合体力恢复至上限。

func on_trigger_20016()->bool:
	if not me.is_war_debuffed():
		return false
	ske.change_actor_hp(actorId, actor.get_max_hp() - int(actor.get_hp()))
	ske.war_report()
	return false
