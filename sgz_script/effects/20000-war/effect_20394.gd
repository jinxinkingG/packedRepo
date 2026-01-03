extends "effect_20000.gd"

#暗杀主动技部分
#【暗杀】大战场，主动技。若你于本场战争未获得过负面状态，你可指定1名敌将作为目标，消耗5点机动力发动。你与目标进入白刃战；仅在此次白刃战中，你的兵力视为0，并获得3动效果。每回合限一次

const EFFECT_ID = 20394
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 5

func on_trigger_20022() -> bool:
	# 简单处理，只要身上有负面 BUFF，技能就进入 CD
	if not me.get_buff_names("大战场", -1).empty():
		ske.ban_war_skill(actorId, ske.skill_name, 99999)
	ske.war_report()
	return false

func effect_20394_start():
	if not assert_action_point(actorId, COST_AP):
		return
	var targets = get_combat_targets(me)
	if not wait_choose_actors(targets, "选择敌军发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2", true)
	return

func effect_20394_2():
	var targetId = DataManager.get_env_int("目标")
	var msg = "消耗{0}点机动力\n孤身潜行，放手一搏\n可否？".format([COST_AP])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3", true)
	return

func effect_20394_3():
	var targetId = DataManager.get_env_int("目标")
	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	ske.set_war_skill_val(1, 1)
	ske.war_report()
	var msg = "不入虎穴，焉得虎子？\n{0}大患也，吾往刺之！".format([
		ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(actorId, msg, 0, 2002)
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_20394_4():
	var targetId = DataManager.get_env_int("目标")
	start_battle_and_finish(actorId, targetId)
	return
