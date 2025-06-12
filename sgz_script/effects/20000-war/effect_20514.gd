extends "effect_20000.gd"

#神佑主动技 #施加状态
#【神佑】大战场，主动技。消耗10点机动力，指定一名己方部队，令其附加2回合 {神佑} 状态。

const EFFECT_ID = 20514
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 10
const BUFF_NAME = "神佑"
const BUFF_LABEL_NAME = "神佑"

func effect_20514_start():
	if not assert_action_point(me.actorId, COST_AP):
		return
	var targets = get_teammate_targets(me)
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20514_2():
	var targetId = DataManager.get_env_int("目标")
	var msg = "消耗{2}机动力\n对{0}发动【{1}】\n可否？".format([
		ActorHelper.actor(targetId).get_name(), ske.skill_name, COST_AP
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20514_3():
	var targetId = DataManager.get_env_int("目标")
	ske.cost_ap(COST_AP, true)
	ske.set_war_buff(targetId, BUFF_NAME, 2)
	ske.war_report()
	goto_step("4")
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_4")
	return

func effect_20514_4():
	report_skill_result_message(ske, 2002)
	return
