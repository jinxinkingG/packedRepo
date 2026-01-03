extends "effect_20000.gd"

# 望梅限定技
#【望梅】大战场，主将限定技。消耗15机动力，你方全体获得五步移动不消耗机动力效果。使用后，你获得<激励>，并失去本技能。

const EFFECT_ID = 20674
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 15
const TARGET_SKILL = "激励"
const PASSIVE_EFFECT_ID = 20263
const FREE_STEPS = 5

func check_AI_perform_20000() -> bool:
	# AI 攻方时考虑发动
	var wv = me.war_vstate()
	if wv == null or not wv.is_attacker():
		return false
	if me.action_point < COST_AP:
		return false
	return true

func effect_20674_AI_start() -> void:
	goto_step("confirmed")
	return

func effect_20674_start() -> void:
	if not assert_action_point(actorId, COST_AP):
		return

	var msg = "消耗{0}机动力，发动【{1}】\n将获得【{2}】\n摧动全军前进，可否？".format([
		COST_AP, ske.skill_name, TARGET_SKILL,
	])
	play_dialog(actorId, msg, 2, 2000)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20674_confirmed() -> void:
	ske.cost_ap(COST_AP, true)
	ske.cost_war_cd(99999)
	ske.set_war_skill_val([FREE_STEPS, ske.skill_name, actorId], 1, PASSIVE_EFFECT_ID, actorId)
	for wa in me.get_teammates(false, true):
		ske.set_war_skill_val([FREE_STEPS, ske.skill_name, actorId], 1, PASSIVE_EFFECT_ID, wa.actorId)
	ske.add_war_skill(actorId, TARGET_SKILL, 99999)
	ske.war_report()

	var msg = "梅林在望，全军速进！\n（全体获得 {0} 步免机移动".format([
		FREE_STEPS, ske.skill_name, TARGET_SKILL,
	])
	report_skill_result_message(ske, 2001, msg, 1)
	return

func on_view_model_2001() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20674_report() -> void:
	report_skill_result_message(ske, 2001)
	return
