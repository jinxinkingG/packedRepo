extends "effect_30000.gd"

#义从效果 #骑兵强化
#【义从】小战场，锁定技。非城战，你的骑兵基础减伤倍率-0.15，可射箭攻击，默认射程3。

const ENHANCEMENT = {
	"射击距离": 3,
	"额外免伤": -0.15,
	"图像": "1-2.png",
	"新图像": "1-2.png",
	"BUFF": 1,
}

func on_trigger_30024():
	ske.battle_enhance_current_unit(ENHANCEMENT, ["骑"])
	return false
