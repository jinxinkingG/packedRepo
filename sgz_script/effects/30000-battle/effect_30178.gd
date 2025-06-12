extends "effect_30000.gd"

#游龙锁定效果
#【游龙】小战场，锁定技。你使用枪类武器时，可以额外攻击斜角。

func check_trigger_correct()->bool:
	var unit = get_leader_unit(self.actorId)
	if unit == null or unit.disabled:
		return false
	if "枪" in unit.get_unit_equip():
		if not unit.dic_combat.has("武器特性"):
			unit.dic_combat["武器特性"] = unit.get_unit_equip()
		unit.dic_combat["武器特性"].append("锤")
	return false
