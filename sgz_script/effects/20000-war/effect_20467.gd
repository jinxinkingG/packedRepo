extends "effect_20000.gd"

#论才主动技
#【论才】大战场，主动技。指定一名敌将为目标，消耗5点机动力发动。立刻刷新目标敌将的点数：若你的点数大，你方主将增加点数差值的机动力。每回合限1次。

const EFFECT_ID = 20467
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 5

# 发动主动技
func effect_20467_start():
	if not assert_action_point(me.actorId, COST_AP):
		return
	if not wait_choose_actors(get_enemy_targets(me)):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2", true)
	return

func effect_20467_2():
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var msg = "消耗{0}机动力\n刷新{1}的点数\n可否？".format([
		COST_AP, targetWA.get_name(),
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20467_3():
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var point = Global.get_random(0, 9)
	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	ske.change_actor_five_phases(targetId, targetWA.five_phases, point)
	var msg = "{0}其人，当善察所行\n（{1}点数变为{2}".format([
		DataManager.get_actor_honored_title(targetId, actorId),
		targetWA.get_name(), targetWA.poker_point,
	])
	if targetWA.poker_point < me.poker_point:
		var diff = me.poker_point - targetWA.poker_point
		var leader = me.get_leader()
		if leader != null:
			ske.change_actor_ap(leader.actorId, diff)
			msg += "\n（{0}机动力增加{1}".format([
				leader.get_name(), diff, leader.action_point,
			])
	play_dialog(actorId, msg, 2, 2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return
