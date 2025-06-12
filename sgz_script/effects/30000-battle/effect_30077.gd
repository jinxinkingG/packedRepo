extends "effect_30000.gd"

#疠火效果
#【疠火】小战场,主动技。你体力＞30时，你可以消耗5点体力，发动本技能，视为发动“火矢”战术效果。每回合限1次

func effect_30077_start():
	if actor.get_hp() <= 30:
		FlowManager.add_flow("tactic_end")
		return false

	ske.cost_war_cd(1)
	ske.battle_cd(99999)
	ske.cost_hp(5)
	ske.battle_report()
	set_env("当前武将", me.actorId)
	FlowManager.add_flow("tactic_impact_4")
	return true
