extends "effect_10000.gd"

#迫继
#【迫继】内政,锁定技。若你为出仕状态，刘协技能禁用。

func on_trigger_10001()->bool:
	SkillHelper.clear_ban_actor_skill(10000, [StaticManager.ACTOR_ID_LIUXIE])
	if not actor.is_status_officed():
		return false
	var skillNames = SkillHelper.get_actor_default_skill_names(StaticManager.ACTOR_ID_LIUXIE)
	for skillName in skillNames.values():
		if skillName == "":
			continue
		SkillHelper.ban_actor_skill(
			10000, StaticManager.ACTOR_ID_LIUXIE, skillName,
			99999, actorId, ske.skill_name
		)
	return false
