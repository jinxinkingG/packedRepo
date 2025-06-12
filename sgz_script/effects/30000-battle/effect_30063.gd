extends "effect_30000.gd"

#无当效果实现
#【无当】小战场,锁定技。你的士兵身披铁甲，基础减伤倍率+0.25。你的兵种默认为6弓4步，且布阵的时候，步兵站在骑兵位。

const ENHANCEMENT = {
	"额外免伤": 0.25,
	"BUFF": 1,
}

func on_trigger_30003() -> bool:
	var formationKey = "白兵.阵型优先.{0}".format([me.actorId])
	if get_env_int(formationKey) > 1:
		return false
	set_env(formationKey, 1)
	set_env("兵种数量", {"步":4,"弓":6,"骑":0})
	set_env("分配顺序", ["弓","步"])
	ske.set_battle_skill_val(1)
	return false

func on_trigger_30024() -> bool:
	if ske.get_battle_skill_val_int() <= 0:
		return false
	ske.battle_enhance_current_unit(ENHANCEMENT, UNIT_TYPE_SOLDIERS)
	return false
