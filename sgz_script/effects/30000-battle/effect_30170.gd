extends "effect_30000.gd"

#精盾效果
#【精盾】小战场，锁定技。你的士兵拥有格挡能力，格挡概率+20%。

const ENHANCEMENT = {
	"格挡率": 20,
	"BUFF": 1,
}

func on_trigger_30024()->bool:
	ske.battle_enhance_current_unit(ENHANCEMENT, UNIT_TYPE_SOLDIERS)
	return false
