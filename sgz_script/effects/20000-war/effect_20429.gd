extends "effect_20000.gd"

#陷功锁定技
#【陷功】大战场，锁定技。若你是己方在场唯一等级最高的将领，你的其他技能失效；否则，你无视等级限制解锁自身所有技能。

func on_trigger_20013()->bool:
	for targetId in get_teammate_targets(me, 999):
		var wa = DataManager.get_war_actor(targetId)
		if wa.actor().get_level() >= actor.get_level():
			# 有人等级还行
			for skillName in SkillHelper.get_actor_locked_skill_names(actorId).values():
				ske.add_war_skill(actorId, skillName, 1)
			ske.war_report()
			return false
	# 等级唯一最高
	for skillName in SkillHelper.get_actor_unlocked_skill_names(actorId).values():
		if skillName == ske.skill_name:
			continue
		ske.ban_war_skill(actorId, skillName, 1)
	ske.war_report()
	return false
