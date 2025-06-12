extends "effect_30000.gd"

#城槌锁定技
#【城槌】小战场，锁定技。城门地形战，你为攻方时，你方单位每次对城门造成的近战伤害+10。

const ENHANCEMENT = {
	"城门增伤": 10,
	"BUFF": 1,
}

func on_trigger_30024():
	ske.battle_enhance_current_unit(ENHANCEMENT, ["步", "骑", "象", "将"])
	return false
