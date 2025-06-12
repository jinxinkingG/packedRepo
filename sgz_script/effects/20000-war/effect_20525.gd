extends "effect_20000.gd"

#强借主动技
#【强借】大战场，君主主动技。你可以指定一个己方其他武将，你复刻其一个锁定技，持续3回合。该己方武将直到战争结束前，禁用被复刻的技能。每5回合限1次。

const EFFECT_ID = 20525
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20525_start() -> void:
	var targets = []
	for targetId in get_teammate_targets(me):
		for skill in SkillHelper.get_actor_skills(targetId, 20000):
			if skill.type == "锁定":
				targets.append(targetId)
				break
	if targets.empty():
		var msg = "无技能可借 ……"
		play_dialog(actorId, msg, 3, 2999)
		return
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20525_2() -> void:
	var targetId = DataManager.get_env_int("目标")
	var skillNames = []
	for skill in SkillHelper.get_actor_skills(targetId, 20000):
		if skill.type == "锁定":
			skillNames.append(skill.name)

	var msg = "【{0}】{1}的哪个技能？".format([
		ske.skill_name, ActorHelper.actor(targetId).get_name(),
	])
	SceneManager.show_unconfirm_dialog(msg, actorId)
	SceneManager.bind_top_menu(skillNames, skillNames, 1)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001() -> void:
	wait_for_choose_skill(FLOW_BASE + "_3")
	return

func effect_20525_3() -> void:
	var targetId = DataManager.get_env_int("目标")
	var skillName = DataManager.get_env_str("目标项")

	ske.cost_war_cd(5)
	ske.add_war_skill(actorId, skillName, 3)
	ske.ban_war_skill(targetId, skillName, 99999)
	ske.war_report()

	var msg = "【{0}】之用\n非吾不能尽！".format([skillName])
	play_dialog(actorId, msg, 0, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_20525_4() -> void:
	var targetId = DataManager.get_env_int("目标")
	var skillName = DataManager.get_env_str("目标项")
	var targetActor = ActorHelper.actor(targetId)

	var msg = "…… ……"
	var distance = actor.personality_distance(targetActor)
	if distance >= 70:
		msg = "残暴不仁，轻贤慢士\n其能久乎！"
	play_dialog(targetId, msg, 0, 2003)
	return

func effect_20525_report() -> void:
	report_skill_result_message(ske, 2003)
	return

func on_view_model_2003() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return
