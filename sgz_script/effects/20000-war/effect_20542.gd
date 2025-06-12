extends "effect_20000.gd"

#宠爵主动技
#【宠爵】大战场，主将限定技。指定1名拥有「主将类」技能的队友发动。令之无视「主将类」技能的“主将”限制，直到回合结束

const EFFECT_ID = 20542
const FLOW_BASE = "effect_" + str(EFFECT_ID)

# 发动主动技
func effect_20542_start() -> void:
	var targets = []
	for targetId in get_teammate_targets(me):
		if targetId == me.get_main_actor_id():
			continue
		for skill in SkillHelper.get_actor_skills(targetId):
			if skill.has_feature("主将"):
				targets.append(targetId)
				break
	if targets.empty():
		var msg = "没有合适的发动对象"
		play_dialog(actorId, msg, 3, 2999)
		return
	var msg = "选择队友发动【{0}】"
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

# 已选定队友
func effect_20542_2() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	ske.cost_war_cd(99999)
	targetWA.set_tmp_variable("无视主将限制", 1)
	ske.war_report()

	var msg = "三军之主，卿亦作得"
	play_dialog(actorId, msg, 2, 2001)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20542_3() -> void:
	var targetId = DataManager.get_env_int("目标")
	var unlocked = []
	for skill in SkillHelper.get_actor_skills(targetId):
		if skill.has_feature("主将"):
			unlocked.append('【' + skill.name + '】')
	var msg = "臣谨受命\n（本回合可发动" + "、".join(unlocked)
	report_skill_result_message(ske, 2002, msg, 0, targetId, false)
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20540_report():
	report_skill_result_message(ske, 2002)
	return
