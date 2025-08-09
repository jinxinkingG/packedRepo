extends "effect_20000.gd"

#速进主动技，及进截效果
#【速进】大战场，主动技。你方米减5%，回合结束前，你移动一步所需机动力-1，且至少为1。每3回合限1次。
#【进截】大战场，锁定技。你发动<速进>后，临时获得<截粮>，持续2回合。

const EFFECT_ID = 20398
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_RICE_RATE = 5
const COST_CD = 3

func check_AI_perform_20000()->bool:
	# 主将不发动
	if actorId == me.get_main_actor_id():
		return false
	# 只有进攻方发动
	if not me.is_attacker():
		return false
	# 兵力不足就别丢人了
	if me.get_soldiers() < 500:
		return false
	# 每人只发动一次，避免米不够了
	if me.get_ext_variable("速进", 0) != 0:
		return false
	me.set_ext_variable("速进", 1)
	return true

func effect_20398_AI_start()->void:
	goto_step("2")
	return

func effect_20398_start():
	var wv = me.war_vstate()
	var cost = int(wv.rice * COST_RICE_RATE / 100)
	if cost <= 0:
		goto_step("2")
	var msg = "消耗{0}米\n加速行军，可否？".format([cost])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

func effect_20398_2():
	var wv = me.war_vstate()
	var cost = int(wv.rice * COST_RICE_RATE / 100)

	ske.cost_war_cd(COST_CD)
	cost = ske.cost_wv_rice(cost)
	ske.set_war_skill_val(1, 1)
	ske.append_message("获得速进效果", me.actorId)
	if SkillHelper.actor_has_skills(actorId, ["进截"]):
		ske.add_war_skill(actorId, "截粮", 2)
	ske.war_report()

	var msg = "机不可失\n让士卒饱餐一顿，速进！".format([
		cost, wv.rice,
	])
	report_skill_result_message(ske, 2001, msg, 0, actorId, false)
	return

func on_view_model_2001():
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20398_report():
	report_skill_result_message(ske, 2001)
	return
