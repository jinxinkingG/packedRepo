extends "effect_20000.gd"

#影咒主动技
#【影咒】大战场，主动技。①你可选择1个五行为“土”的其他武将发动。你与目标各自选择1个 {常规技能} 交换给对方，直到本回合结束。<影咒>不可交换，每个回合限1次。②你视为拥有 <地术>。

const EFFECT_ID = 20363
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20363_start():
	var targets = []
	for targetId in get_teammate_targets(me):
		var wa = DataManager.get_war_actor(targetId)
		if wa.five_phases != War_Character.FivePhases_Enum.Earth:
			continue
		if SkillHelper.get_actor_skill_names(wa.actorId, -1, true).empty():
			continue
		targets.append(targetId)
	for targetId in get_enemy_targets(me):
		var wa = DataManager.get_war_actor(targetId)
		if wa.five_phases != War_Character.FivePhases_Enum.Earth:
			continue
		var targetSkills = SkillHelper.get_actor_skill_names(wa.actorId, -1, true)
		if targetSkills.empty():
			continue
		if "贞烈" in targetSkills:
			continue
		targets.append(targetId)
	if targets.empty():
		play_dialog(me.actorId, "没有可发动的目标", 3, 2009)
		return
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20363_2():
	var targetId = DataManager.get_env_int("目标")
	DataManager.set_env("技能.影咒.对象", targetId)
	var skills = SkillHelper.get_actor_skill_names(targetId, -1, true)
	skills.erase("影咒")
	SceneManager.show_unconfirm_dialog("换取哪个技能？", actorId)
	bind_menu_items(skills, skills, 2)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001():
	wait_for_choose_skill(FLOW_BASE + "_3")
	return

func effect_20363_3():
	var targetId = get_env_int("技能.影咒.对象")
	var skill = get_env_str("目标项")
	set_env("技能.影咒.目标", skill)
	var skills = SkillHelper.get_actor_skill_names(actorId, -1, true)
	skills.erase("影咒")
	var target = DataManager.get_war_actor(targetId)
	if target.get_controlNo() < 0:
		skills.shuffle()
		set_env("目标项", skills[0])
		var msg = "{0}选择了【{1}】".format([
			target.get_name(), skills[0],
		])
		play_dialog(me.actorId, msg, 2, 2003)
		return
	SceneManager.show_unconfirm_dialog("换取哪个技能？", targetId)
	bind_menu_items(skills, skills, 2)
	LoadControl.set_view_model(2002)
	return

func on_view_model_2002():
	wait_for_choose_skill(FLOW_BASE + "_4")
	return

func on_view_model_2003():
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_20363_4():
	var targetId = get_env_int("技能.影咒.对象")
	var mySkill = get_env_str("目标项")
	var targetSkill = get_env_str("技能.影咒.目标")

	ske.cost_war_cd(1)
	if not ske.ban_war_skill(actorId, mySkill, 1):
		play_dialog(me.actorId, "【{0}】不可交换！".format([mySkill]), 2, 2005)
		return
	if not ske.ban_war_skill(targetId, targetSkill, 1):
		play_dialog(me.actorId, "【{0}】不可交换！".format([targetSkill]), 2, 2005)
		return
	ske.add_war_skill(actorId, targetSkill, 1)
	ske.add_war_skill(targetId, mySkill, 1)

	var msg = "换手如换刀\n胜负之所，当在精微"
	report_skill_result_message(ske, 2004, msg, 2, actorId)
	return

func on_view_model_2004():
	wait_for_pending_message(FLOW_BASE + "_5")
	return

func on_view_model_2005():
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_20363_5():
	report_skill_result_message(ske, 2004)
	return

func on_view_model_2009():
	wait_for_skill_result_confirmation()
	return

