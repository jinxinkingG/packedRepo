extends "effect_20000.gd"

#解音、苦谏等技能的效果部分，根据 BUFF 给队友加命中率

func on_trigger_20017()->bool:
	var buffed = ske.get_scheme_chance_enhancement(ske.actorId)
	if buffed <= 0:
		return false
	change_scheme_chance(ske.actorId, ske.skill_name, buffed)
	return false
