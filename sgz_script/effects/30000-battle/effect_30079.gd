extends "effect_30000.gd"

#硬弩技能实现
#【硬弩】小战场,锁定技。你方弓兵对对方士兵造成的伤害结果+8。

const EXTRA_DAMAGE = 8

func on_trigger_30021() -> bool:
	var bu = ske.battle_extra_damage(EXTRA_DAMAGE, ["弓"], ["ALL"])
	if bu == null:
		return false
	var msg = "{0} +{1}#FF0000".format([ske.skill_name, EXTRA_DAMAGE])
	bu.add_status_effect(msg)
	return false
