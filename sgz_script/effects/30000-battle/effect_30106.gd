extends "effect_30000.gd"

#鼓进效果
#【鼓进】小战场,锁定技。你的战术值+3

func on_trigger_30005()->bool:
	ske.battle_change_tactic_point(3)
	ske.battle_report()
	return false
