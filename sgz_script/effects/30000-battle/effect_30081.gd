extends "effect_30000.gd"

#振奋效果
#【振奋】小战场，锁定技。你方士兵基础攻击倍率+0.06，基础减伤倍率+0.06。

const ENHANCEMENT = {
	"额外伤害": 0.06,
	"额外免伤": 0.06,
	"BUFF": 1,
}

func on_trigger_30024():
	ske.battle_enhance_current_unit(ENHANCEMENT, UNIT_TYPE_SOLDIERS)
	return false
