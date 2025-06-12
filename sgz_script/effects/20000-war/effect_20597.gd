extends "effect_20000.gd"

# 都督锁定效果
#【都督】大战场，规则技。你非主将时，每回合机动力回复+5；你为主将时，非主将技能禁用。

func on_trigger_20013() -> bool:
	if me.get_main_actor_id() == actorId:
		for skill in SkillHelper.get_actor_skills(actorId):
			if skill.name == ske.skill_name:
				continue
			if not skill.has_feature("主将"):
				ske.ban_war_skill(actorId, skill.name, 99999)
	else:
		ske.change_actor_ap(actorId, 5)
	ske.war_report()
	return false
