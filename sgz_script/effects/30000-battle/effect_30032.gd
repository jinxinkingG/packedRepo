extends "effect_30000.gd"

#盾守锁定技 #弓兵强化
#【盾守】小战场,锁定技。非城地形，你为守方，你的弓兵获得6%的伤害加成，你的骑兵获得25%的免伤效果。

const ENHANCEMENT_ARCHER = {
	"额外伤害": 0.06,
	"BUFF": 1,
}

const ENHANCEMENT_RIDER = {
	"额外免伤": 0.25,
	"BUFF": 1,
}

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	ske.battle_enhance_current_unit(ENHANCEMENT_ARCHER, ["弓"])
	ske.battle_enhance_current_unit(ENHANCEMENT_RIDER, ["骑"])
	return false
