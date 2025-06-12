extends "effect_20000.gd"

#节钺效果实现
#【节钺】大战场，主将诱发技。你忠99时，战争初始，你可以选择你方君主的一个战斗类主将技或战斗类君主技，附加给自己。

const EFFECT_ID = 20414
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20019()->bool:
	# 仅第一天允许发动
	var wf = DataManager.get_current_war_fight()
	if wf.date != 1:
		return false
	# 先设 CD，无论行不行只判断一次
	ske.cost_war_cd(99999)

	if me.actor().get_loyalty() != 99:
		return false
	var lordId = me.get_lord_id()
	var lordSkillNames = SkillHelper.get_actor_unlocked_skill_names(lordId).values()
	var mySkillNames = SkillHelper.get_actor_unlocked_skill_names(actorId).values()
	var targets = []
	for skillName in lordSkillNames:
		if skillName in mySkillNames:
			continue
		var skill = StaticManager.get_skill(skillName)
		if skill == null:
			continue
		if not skill.has_feature("主将"):
			continue
		if skill.has_feature("君主"):
			continue
		for effect in skill.effects:
			if effect.id >= 20000:
				targets.append(skill.name)
				break
	DataManager.set_env("战争.技能.节钺.来源", lordId)
	DataManager.set_env("战争.技能.节钺.备选", targets)
	return targets.size() > 0

func effect_20414_AI_start():
	var skills = DataManager.get_env_array("战争.技能.节钺.备选")
	if skills.empty():
		LoadControl.end_script()
		return
	skills.shuffle()
	DataManager.set_env("目标项", skills[0])
	goto_step("2")
	return

func effect_20414_start():
	var lordId = DataManager.get_env_int("战争.技能.节钺.来源")
	var skills = DataManager.get_env_array("战争.技能.节钺.备选")
	var msg = "请选择{1}的一个技能".format([
		ske.skill_name, ActorHelper.actor(lordId).get_name(),
	])
	SceneManager.show_unconfirm_dialog(msg)
	bind_menu_items(skills, skills, 1)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_skill(FLOW_BASE + "_2", false, false)
	return

func effect_20414_2():
	var lordId = DataManager.get_env_int("战争.技能.节钺.来源")
	var skill = DataManager.get_env_str("目标项")
	ske.add_war_skill(me.actorId, skill, 99999)
	ske.war_report()
	var msg = "【{0}】在手\n必不负{1}所托！\n（{2}临时获得【{3}】".format([
		ske.skill_name, DataManager.get_actor_honored_title(lordId, me.actorId),
		me.get_name(), skill,
	])
	play_dialog(me.actorId, msg, 0, 2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation("")
	return
