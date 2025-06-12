extends "effect_30000.gd"

#侠名效果实现
#你用（德+智-20）代替智，计算你的战术值。

func on_trigger_30006()->bool:
	var sbp = ske.get_battle_skill_property()
	var wisdom = max(1, actor.get_moral() + actor.get_wisdom() - 20)
	sbp.alternative_wisdom_for_tp = wisdom
	ske.apply_battle_skill_property(sbp)
	ske.battle_report()
	return false
