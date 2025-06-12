extends "effect_30000.gd"

#炎弓效果实现
#【炎弓】小战场,锁定技。你射箭攻击，附带单次火矢效果。

const ENHANCEMENT = {
	"火矢": 99999,
}

func on_trigger_30024()->bool:
	ske.battle_enhance_current_unit(ENHANCEMENT, ["将"])
	return false
