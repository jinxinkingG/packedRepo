extends "effect_20000.gd"

# 决讨主动技部分
#【决讨】大战场，限定技。体力<40才能发动。你直到回合结束前获得<奋威><勇进>。

const EFFECT_ID = 20573
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const TARGET_SKILLS = ["奋威", "勇进"]

func effect_20573_start() -> void:
	if actor.get_hp() >= 40:
		var msg = "未到生死关\n尚可隐忍 ……"
		play_dialog(actorId, msg, 2, 2999)
		return

	var msg = "发动【{0}】\n本回合获得【{1}】\n可否？".format([
		ske.skill_name, "】【".join(TARGET_SKILLS),
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20573_confirmed() -> void:
	ske.cost_war_cd(99999)
	for skillName in TARGET_SKILLS:
		ske.add_war_skill(actorId, skillName, 1)
	ske.war_report()

	var msg = "岂能坐受败辱\n今当自出讨贼！"
	report_skill_result_message(ske, 2001, msg, 0, actorId)
	return

func on_view_model_2001() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20573_report() -> void:
	report_skill_result_message(ske, 2001)
	return
