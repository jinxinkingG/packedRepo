extends "effect_30000.gd"

#铁壁锁定技
#【铁壁】小战场，锁定技。你和你的士兵基础减伤倍率+0.1

const ENHANCEMENT = {
	"额外免伤": 0.1,
	"BUFF": 1,
}

func on_trigger_30024()->bool:
	ske.battle_enhance_current_unit(ENHANCEMENT, [])
	return false
