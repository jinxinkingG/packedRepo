extends "effect_20000.gd"

#智援防御效果 #计策防御
#【智援】大战场，诱发技。与你相邻的你方武将，使用计策或者被用计的场合，你可以消耗3点机动力发动：你代替该武将执行本次计策结算。每个回合限3次。

const EFFECT_ID = 20339
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 3
const PASSIVE_EFFECT_ID = 20281
const LIMIT = 3

func on_trigger_20038() -> bool:
	if actorId == ske.actorId:
		return false
	if me.action_point < COST_AP:
		return false
	var se = DataManager.get_current_stratagem_execution()
	var teammate = DataManager.get_war_actor(se.targetId)
	if teammate == null or teammate.disabled:
		return false
	if Global.get_distance(teammate.position, me.position) != 1:
		return false
	return ske.get_war_limited_times() < LIMIT

func effect_20339_AI_start():
	var se = DataManager.get_current_stratagem_execution()
	se.goback_disabled = 1
	var msg = "不出我之所料\n（{0}发动【{1}】\n（替代{2}计防".format([
		actor.get_name(), ske.skill_name,
		ActorHelper.actor(se.targetId).get_name(),
	])
	play_dialog(actorId, msg, 0, 3000)
	return

func on_view_model_3000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_20339_start():
	var se = DataManager.get_current_stratagem_execution()
	var msg = "消耗{0}机动力，发动【{1}】\n替代{2}计防\n可否？".format([
		COST_AP, ske.skill_name, ActorHelper.actor(se.targetId).get_name(),
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_2", false)
	return

func effect_20339_2() -> void:
	var se = DataManager.get_current_stratagem_execution()

	ske.cost_ap(COST_AP)
	ske.cost_war_limited_times(LIMIT)
	ske.war_report()
	se.set_replaced_defender(ske.skill_actorId, ske.skill_name)
	LoadControl.end_script()
	return
