extends "effect_20000.gd"

# 群英主动技
#【群英】大战场，主将限定技。己方所有武将的武、知、统临时+8，持续到你方下个回合开始之前。

const EFFECT_ID = 20600
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const BUFF = 8

func check_AI_perform_20000() -> bool:
	# 检查主将附近是不是有敌军
	return get_enemy_targets(me).size() >= 2

func effect_20600_AI_start() -> void:
	goto_step("confirmed")
	return

func effect_20600_start() -> void:
	var msg = "发动限定技【{0}】\n令我方全体获得属性加强\n可否？".format([
		ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20600_confirmed() -> void:
	var targetIds = []
	for wa in me.get_teammates(false, true):
		targetIds.append(wa.actorId)
	targetIds.insert(0, actorId)
	for targetId in targetIds:
		ske.change_war_power(targetId, BUFF)
		ske.change_war_wisdom(targetId, BUFF)
		ske.change_war_leadership(targetId, BUFF)

	ske.set_war_skill_val(targetIds)

	ske.cost_war_cd(99999)
	ske.war_report()

	var msg = "江表群英，群集于此\n诸公，腾蛟一跃，更待何日！"
	report_skill_result_message(ske, 2001, msg, 0)
	return

func on_view_model_2001()->void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20600_report():
	report_skill_result_message(ske, 2001)
	return
