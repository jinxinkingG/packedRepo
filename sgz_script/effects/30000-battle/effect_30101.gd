extends "effect_30000.gd"

#玄阵效果
#【玄阵】小战场，锁定技。你的士兵基础伤害倍率+0.1，并获得格挡效果，格挡率 30%。

const ENHANCEMENT = {
	"额外伤害": 0.1,
	"格挡率": 30,
	"BUFF": 1,
}

func on_trigger_30024()->bool:
	ske.battle_enhance_current_unit(ENHANCEMENT, UNIT_TYPE_SOLDIERS)
	return false
