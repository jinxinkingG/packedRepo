extends "effect_30000.gd"

#远射效果实现
#【远射】小战场，锁定技。你射箭攻击时，自带强弩效果。

const ENHANCEMENT = {
	"视同强弩": 1,
	"BUFF": 1,
}

func on_trigger_30024()->bool:
	ske.battle_enhance_current_unit(ENHANCEMENT, ["将"])
	return false
