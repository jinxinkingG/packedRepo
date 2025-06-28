extends "effect_20000.gd"

#良策效果实现
#【良策】大战场,锁定技。你使用伤兵类计策时，命中率额外+5%

func on_trigger_20017()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	change_scheme_chance(actorId, ske.skill_name, 5)
	return false
