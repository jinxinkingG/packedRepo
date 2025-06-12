extends "effect_30000.gd"

#猛攻技能实现
#【猛攻】小战场,锁定技。你为白兵攻方，你的武临时+你的等级，战术值+3

func on_trigger_30006() -> bool:
	var sbp = ske.get_battle_skill_property()
	sbp.power += actor.get_level()
	sbp.tp += 3
	ske.apply_battle_skill_property(sbp)
	ske.battle_report()
	return false
