extends "effect_30000.gd"

#善平效果
#【善平】小战场,锁定技。你在平地和沙漠时，你的统+10。

func on_trigger_30006() -> bool:
	var sbp = ske.get_battle_skill_property()
	sbp.leader += 10
	ske.apply_battle_skill_property(sbp)
	ske.battle_report()
	return false
