extends "effect_30000.gd"

#勇决效果实现
#【勇决】小战场,锁定技。你的武将攻击倍率+武器重量%。

func on_trigger_30024():
	var weight = actor.weapon_weight()
	if weight <= 0:
		return false
	var enhancement = {
		"额外伤害": weight / 100.0,
		"BUFF": 1,
	}
	ske.battle_enhance_current_unit(enhancement, ["将"])
	return false
