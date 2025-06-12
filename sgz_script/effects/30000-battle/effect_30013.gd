extends "effect_30000.gd"

#藤兵效果实现
#【藤兵】小战场,锁定技。非水战，你的步兵被对方士兵攻击时，反弹本次实际伤害的40%。

const ENHANCEMENT = {
	"反伤倍率": 0.4,
	"BUFF": 1,
}

func check_trigger_correct():
	var ske = SkillHelper.read_skill_effectinfo()
	ske.battle_enhance_current_unit(ENHANCEMENT, ["步"])
	return false
