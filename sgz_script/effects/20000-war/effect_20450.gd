extends "effect_20000.gd"

#清侧主动技
#【清侧】大战场，主将主动技。你为守方的场合，消耗5点机动力才能发动。双方所有与太守府距离=1的将领，强制后退；若退到的位置是城墙，重复此步骤。每回合1次。

const EFFECT_ID = 20450
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 5

func effect_20450_start():
	if me.side() != "防守方":
		var msg = "仅守方可发动"
		play_dialog(actorId, msg, 2, 2999)
		return
	var targets = []
	var pos = map.get_position_by_buildCN("太守府")
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var p = pos + dir
		var wa = DataManager.get_war_actor_by_position(p)
		if wa == null or wa.disabled:
			continue
		targets.append(wa)
	if targets.empty():
		var msg = "影响范围内没有目标"
		play_dialog(actorId, msg, 2, 2999)
		return
	if not assert_action_point(actorId, COST_AP):
		return
	var msg = "发动【{0}】\n令紧邻太守府的部队退避\n可否？".format([
		ske.skill_name
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_20450_2():
	var targets = []
	var pos = map.get_position_by_buildCN("太守府")
	var moved = false
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var p = pos + dir
		var wa = DataManager.get_war_actor_by_position(p)
		if wa == null or wa.disabled:
			continue
		if wa.can_move_to_position(p + dir):
			wa.move(p + dir, false)
			moved = true
			continue
		for next in StaticManager.NEARBY_DIRECTIONS:
			if wa.can_move_to_position(wa.position + next):
				wa.move(wa.position + next, true)
				moved = true
				break
	ske.cost_ap(COST_AP, true)
	ske.cost_war_cd(1)
	ske.war_report()
	if moved:
		FlowManager.add_flow("draw_actors")
		var msg = "腹心所在，岂容他人放肆！"
		play_dialog(actorId, msg, 0, 2999)
	else:
		var msg = "腹心所在，竟无转圜余地！"
		play_dialog(actorId, msg, 3, 2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return
