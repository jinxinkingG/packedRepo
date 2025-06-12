extends "effect_20000.gd"

#福将效果
#【福将】大战场,锁定技。每回合开始若你：五行为木、火，则你的体力恢复+点数；五行为金、水，则你的机动力+点数。五行为土，则你的体力恢复+点数，同时你的机动力+点数。

func on_trigger_20013()->bool:
	if me.poker_point == 0:
		return false
	match me.five_phases:
		War_Character.FivePhases_Enum.Wood:
			ske.change_actor_hp(me.actorId, me.poker_point)
		War_Character.FivePhases_Enum.Fire:
			ske.change_actor_hp(me.actorId, me.poker_point)
		War_Character.FivePhases_Enum.Metal:
			ske.change_actor_ap(me.actorId, me.poker_point)
		War_Character.FivePhases_Enum.Water:
			ske.change_actor_ap(me.actorId, me.poker_point)
		War_Character.FivePhases_Enum.Earth:
			ske.change_actor_hp(me.actorId, me.poker_point)
			ske.change_actor_ap(me.actorId, me.poker_point)
	ske.war_report()
	return false
