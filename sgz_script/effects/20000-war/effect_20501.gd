extends "effect_20000.gd"

#纳贿锁定效果
#【纳贿】大战场，诱发技。你受到计策伤害的场合，发动：对方需选择，是否将100～500金交给你，若对方给金，则你的永久标记[金]+该金数，且该回合，你周围6格内的你方武将被用计时，施计方命中率+X（X=交给你的金/25）；否则，你恢复本次计策伤害一半的士兵数。每个回合限1次

const ACTIVE_EFFECT_ID = 20500

func on_trigger_20017()->bool:
	var gold = ske.get_war_skill_val_int(ACTIVE_EFFECT_ID)
	if gold <= 0:
		return false
	var se = DataManager.get_current_stratagem_execution()
	if se.targetId != actorId:
		if se.targetId < 0:
			return false
		var target = DataManager.get_war_actor(se.targetId)
		if not me.is_teammate(target):
			return false
		if Global.get_range_distance(me.position, target.position) > 6:
			return false
	change_scheme_chance(actorId, ske.skill_name, int(gold / 25))
	return false
