extends "effect_30000.gd"

#令旗效果
#【令旗】小战场,锁定技。你的统临时+5

func on_trigger_30006() -> bool:
	var sbp = ske.get_battle_skill_property()
	sbp.leader += 5
	ske.apply_battle_skill_property(sbp)
	ske.battle_report()
	return false
