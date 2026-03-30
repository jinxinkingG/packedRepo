extends "effect_30000.gd"

#铁骑小战场生效 #骑兵强化
#【铁骑】小战场，锁定技。非城战，布阵后可以额外消耗X点机动力，使本次白刃战，你的骑兵：获得3动效果，减伤倍率+0.05*X。X=本日内发动此技能的次数。

const ACTIVE_EFFECT_ID = 30124

func on_trigger_30024() -> bool:
	var x = ske.get_war_skill_val_int(ACTIVE_EFFECT_ID)
	if x <= 0:
		return false
	var enhancement = {
		"额外免伤": x * 0.05,
		"行动次数": 3,
		"BUFF": 1,
	}
	ske.battle_enhance_current_unit(enhancement, ["骑"])
	return false
