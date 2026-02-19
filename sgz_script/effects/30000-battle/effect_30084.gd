extends "effect_30000.gd"

#义从效果 #骑兵强化
#【义从】小战场，锁定技。非城战，你拥有弓骑兵。弓骑兵：默认可对2-3距离的敌人进行射箭攻击，基础伤害倍率0.7，基础减伤倍率-0.15。

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
