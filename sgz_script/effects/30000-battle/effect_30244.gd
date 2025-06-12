extends "effect_30000.gd"

#藏机锁定技
#【藏机】小战场，锁定技。你机动力为0的场合，每回合战术值+1，最大增至8点。

func on_trigger_30009()->bool:
	if me.action_point > 0:
		return false
	if me.battle_tactic_point >= 8:
		return false
	ske.battle_change_tactic_point(1)
	ske.battle_report()
	return false
