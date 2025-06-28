extends "effect_20000.gd"

#宠爵主动技
#【宠爵】大战场，君主限定技。指定1名拥有「主将类」技能的队友发动。令之无视「主将类」技能的“主将”限制，持续3回合。

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
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

# 已选定队友
func effect_20542_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	ske.cost_war_cd(99999)
	for wa in me.get_teammates(false):
		ske.remove_war_buff(wa.actorId, "主将授权")
	ske.set_war_buff(targetId, "主将授权", 3)
	ske.war_report()

	SkillHelper.update_all_skill_buff(ske.skill_name)
	var msg = "三军之主，卿亦作得"
	play_dialog(actorId, msg, 2, 2001)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_confirmed")
	return

func effect_20542_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	var turns = targetWA.get_buff_label_turn(["主将授权"])
	var msg = "臣谨受命\n必不负陛下所望".format([turns])
	report_skill_result_message(ske, 2002, msg, 0, targetId, false)
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20542_report():
	report_skill_result_message(ske, 2002)
	return
