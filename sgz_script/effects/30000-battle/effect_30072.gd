extends "effect_30000.gd"

#甲骑技能实现 #骑兵强化
#【甲骑】小战场,锁定技。非城战，你的骑兵基础减伤倍率+0.18，基础伤害倍率-0.06

const EFFECT_ID = 30072

const ENHANCEMENT = {
	"额外伤害": -0.06,
	"额外免伤": 0.18,
	"BUFF": 1,
}

func check_trigger_correct():
	var ske = SkillHelper.read_skill_effectinfo()
	ske.battle_enhance_current_unit(ENHANCEMENT, ["骑"])
	return false
