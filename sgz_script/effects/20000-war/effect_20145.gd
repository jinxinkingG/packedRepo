extends "effect_20000.gd"

#水淹
#【水淹】大战场,锁定技。你使用水类计策时，伤害+10%，并用“武”替代“知”计算命中率及伤害。

func on_trigger_20011() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	if se.get_nature() != "水":
		return false
	change_scheme_damage_rate(10)
	return false

func on_trigger_20017() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	if se.get_nature() != "水":
		return false
	var diff = actor.get_power() - actor.get_wisdom()
	if diff <= 0:
		return false
	change_scheme_chance(actorId, ske.skill_name, diff)
	return false
