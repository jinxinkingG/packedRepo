extends "effect_30000.gd"

#马槊锁定技 #骑兵强化
#【马槊】小战场,锁定技。非城战，你的骑兵：攻击距离变为1～2，对士兵造成伤害结果+8。

const ENHANCEMENT = {
	"近战距离": 2,
}

const DAMAGE = 8

func on_trigger_30021() -> bool:
	var bu = ske.battle_extra_damage(DAMAGE, ["骑"], ["ALL"])
	if bu == null:
		return false
	bu.add_status_effect("马槊 +{0}#FF0000".format([DAMAGE]))
	return false

func on_trigger_30024() -> bool:
	ske.battle_enhance_current_unit(ENHANCEMENT, ["骑"])
	return false;
