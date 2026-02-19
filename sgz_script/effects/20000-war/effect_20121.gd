extends "effect_20000.gd"

#解音、苦谏等技能的效果部分，根据 BUFF 给队友加命中率
#【解音】大战场，主动技。你可以消耗2点机动力，指定一个你方武将，该武将本回合伤兵计命中率加X，X＝该武将点数%，每个回合限1次。

func on_trigger_20017()->bool:
	var buffed = ske.get_scheme_chance_enhancement(ske.actorId)
	if buffed <= 0:
		return false
	change_scheme_chance(ske.actorId, ske.skill_name, buffed)
	return false
