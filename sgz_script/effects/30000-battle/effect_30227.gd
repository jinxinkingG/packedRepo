extends "effect_30000.gd"

#枪术锁定技 #布阵 #武将强化
#【枪术】小战场，锁定技。你持枪时，基础伤害倍率+0.1

const ENHANCEMENT = {
	"额外伤害": 0.1,
	"BUFF": 1,
}

func on_trigger_30024()->bool:
	ske.battle_enhance_current_unit(ENHANCEMENT, ["将"], "枪")
	return false
