extends "effect_30000.gd"

#长弓技能实现
#【长弓】小战场,锁定技。你的弓兵射程+1。

const ENHANCEMENT = {
	"额外射程": 1,
	"BUFF": 1,
}

func on_trigger_30024()->bool:
	ske.battle_enhance_current_unit(ENHANCEMENT, ["弓"])
	return false
