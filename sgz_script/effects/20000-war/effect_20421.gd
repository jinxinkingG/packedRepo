extends "effect_20000.gd"

#转机主动技
#【转机】大战场，主动技。你方存在机动力为0的武将时才能发动。将那些武将的五行点数转为机动力，点数变为0。每回合限1次。

const EFFECT_ID = 20421
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20421_start():
	var targets = []
	for targetId in get_teammate_targets(me):
		var wa = DataManager.get_war_actor(targetId)
		if wa.action_point > 0:
			continue
		if wa.poker_point == 0:
			continue
		targets.append(targetId)
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20421_2():
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)
	var msg = "将{0}的点数清零\n机动力+{1}\n可否？".format([
		wa.get_name(), wa.poker_point,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20421_3():
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)
	ske.cost_war_cd(1)
	ske.change_actor_ap(wa.actorId, wa.poker_point)
	ske.change_actor_five_phases(wa.actorId, wa.five_phases, 0)

	var msg = "战机一瞬，{0}善察之".format([
		DataManager.get_actor_honored_title(wa.actorId, actorId)
	])
	report_skill_result_message(ske, 2002, msg, 1)
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_4")
	return

func effect_20421_4():
	report_skill_result_message(ske, 2002)
	return
