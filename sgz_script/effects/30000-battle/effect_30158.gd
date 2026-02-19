extends "effect_30000.gd"

#千驹被动效果 #骑兵强化
#【千驹】小战场，主动技。非城战才能发动，你的步兵和弓兵全部上马变为骑兵，但每回合你的战术值-1，效果持续至你的战术值为0。

func on_trigger_30009() -> bool:
	if ske.get_battle_skill_val_int() <= 0:
		return false
	me.battle_tactic_point = max(0, me.battle_tactic_point - 1)
	if me.battle_tactic_point > 0:
		return false
	ske.set_battle_skill_val(0)
	for bu in bf.battle_units(actorId):
		if bu.get_unit_type() != "骑":
			continue
		bu.reset_initial_type()
	return false
