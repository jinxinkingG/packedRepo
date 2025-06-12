extends "effect_10000.gd"

#压制内政效果
#【压制】内政&大战场，君主锁定技。1.大战场，你方总兵力＞对方时，对方白刃战中，无法使用战术。2.内政，你方出征时，若选定的主将没有主将技，你可以使其附加【压制*】。

const TARGET_SKILL = "压制*"

func on_trigger_10011()->bool:
	if wf.sendActors.empty() or ske.actorId != wf.sendActors[0]:
		return false
	for skill in SkillHelper.get_actor_skills(ske.actorId):
		if skill.has_feature("主将"):
			return false
		if skill.name == TARGET_SKILL:
			return false
		if skill.name == ske.skill_name:
			return false
	SkillHelper.add_actor_scene_skill(10000, ske.actorId, TARGET_SKILL, 1, ske.skill_actorId, ske.skill_name)
	var messages = wf.get_env_array("攻击宣言")
	var msg = "使{0}有子如{1}\n死复何恨？\n（{2}获得【{3}】".format([
		actor.get_short_name(),
		DataManager.get_actor_honored_title(ske.actorId, actorId),
		ActorHelper.actor(ske.actorId).get_name(),
		TARGET_SKILL,
	])
	messages.append([msg, actorId, 1])
	wf.set_env("攻击宣言", messages)
	return false
