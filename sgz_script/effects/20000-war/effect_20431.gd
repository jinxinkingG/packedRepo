extends "effect_20000.gd"

#合围锁定技
#【合围】大战场，锁定技。场上每存在1个与你拥有重复技能（包括该技能）的队友，你的“统”临时+1，至多以此法升至99。

func on_trigger_20013()->bool:
	var skills = SkillHelper.get_actor_skill_names(actorId)
	var x = 0
	var teammates = get_teammate_targets(me, 999)
	for targetId in teammates:
		for skill in SkillHelper.get_actor_skill_names(targetId):
			if skill in skills:
				x += 1
				break
	var prev = ske.get_war_skill_val_int()
	if x != prev:
		ske.change_war_leadership(actorId, x - prev)
		ske.set_war_skill_val(x)
	ske.war_report()
	return false
