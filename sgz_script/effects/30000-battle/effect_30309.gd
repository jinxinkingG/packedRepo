extends "effect_30000.gd"

# 密甲效果
#【密甲】白刃战，锁定技。战争开始时，若你点数＞0，你的护甲值+你的点数。

func on_trigger_30005() -> bool:
	var bu = me.battle_actor_unit()
	if bu == null:
		return false
	if me.poker_point <= 0:
		return false
	ske.battle_change_unit_armor(bu, me.poker_point)
	ske.battle_report()
	return false
