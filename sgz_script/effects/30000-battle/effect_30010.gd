extends "effect_30000.gd"

#射戟效果实现
#【射戟】小战场,锁定技。你射箭时射程+1，射箭伤害的基础倍率+0.1

const ENHANCEMENT = {
	"额外射程": 1,
	"射击伤害": 0.1,
	"BUFF": 1,
}

func on_trigger_30024()->bool:
	ske.battle_enhance_current_unit(ENHANCEMENT, ["将"])
	return false
