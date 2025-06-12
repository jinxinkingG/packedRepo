extends "effect_30000.gd"

#力劈锁定技 #武将强化
#【力劈】小战场，锁定技。你持刀横劈多个单位时，总伤害由原本150%提升为180%（横劈命中2人）、200%（横劈命中3人）。

const REQUIRED_WEAPON_TYPE = "刀"
const ENHANCEMENT = {
	"刀倍率2": 1.8,
	"刀倍率x": 2.0,
	"BUFF": 1,
}

func on_trigger_30024()->bool:
	ske.battle_enhance_current_unit(ENHANCEMENT, ["将"], REQUIRED_WEAPON_TYPE)
	return false
