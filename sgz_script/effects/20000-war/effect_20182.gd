extends "effect_20000.gd"

#水憩效果实现
#【水憩】大战场,锁定技。回合初始，若你在水地形，则你的体力+3，机动力恢复+2

func on_trigger_20013()->bool:
	ske.change_actor_hp(actorId, 3)
	ske.change_actor_ap(actorId, 2)
	ske.war_report()
	return false
