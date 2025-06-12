extends "effect_20000.gd"

#成谶主动技
#【成谶】大战场，限定技。指定一个智力或等级不高于你的武将为目标，消耗5点机动力才能发动。目标武将的点数减少X，且不会因刷新更改点数，直到回合结束（X=你的等级）。

const EFFECT_ID = 20468
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 5

func effect_20468_start():
	if not assert_action_point(me.actorId, COST_AP):
		return
	var targets = []
	for targetId in get_enemy_targets(me):
		var wa = DataManager.get_war_actor(targetId)
		if wa.actor().get_wisdom() <= me.actor().get_wisdom():
			targets.append(targetId)
		if wa.actor().get_level() <= me.actor().get_level():
			targets.append(targetId)
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2", true)
	return

func effect_20468_2():
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var x = actor.get_level()
	var msg = "消耗{0}机动力\n令{1}的点数-{2}\n可否？".format([
		COST_AP, targetWA.get_name(), x
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20468_3():
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var x = actor.get_level()
	var point = max(0, targetWA.poker_point - x)
	ske.cost_war_cd(99999)
	ske.cost_ap(COST_AP, true)
	ske.change_actor_five_phases(targetId, targetWA.five_phases, point)
	var msg = "{0}其人，究竟无行之辈\n（{1}点数变为{2}\n（且不可刷新".format([
		DataManager.get_actor_honored_title(targetId, actorId),
		targetWA.get_name(), targetWA.poker_point,
	])
	targetWA.set_tmp_variable("固定点数", targetWA.poker_point)
	play_dialog(actorId, msg, 2, 2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return
