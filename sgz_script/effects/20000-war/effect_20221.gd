extends "effect_20000.gd"

#截杀诱发技 #追击
#【截杀】大战场,诱发技。你6格范围内的对方武将，其白兵失败的场合，你可以消耗5点机动力，立即对该武将发起白兵宣言。每回合限1次。

const EFFECT_ID = 20221
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 5

func on_trigger_20050() -> bool:
	# 托管模式下不发动
	if me.war_vstate().delegated:
		return false
	if me == null or me.disabled:
		return false
	var bf = DataManager.get_current_battle_fight()
	var loser = bf.get_loser()
	if loser == null or loser.disabled:
		return false
	if ske.actorId != loser.actorId:
		return false
	if Global.get_range_distance(me.position, loser.position) > 6:
		return false
	if me.action_point < COST_AP:
		return false
	return true

func effect_20221_AI_start():
	goto_step("2")
	FlowManager.add_flow(FLOW_BASE + "_2")
	return

func effect_20221_start():
	var bf = DataManager.get_current_battle_fight()
	var msg = "消耗{0}机动力\n对{1}发动【{2}】\n可否".format([
		COST_AP, bf.get_loser().get_name(), ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_2", false)
	return

func effect_20221_2():
	var bf = DataManager.get_current_battle_fight()
	var loser = bf.get_loser()

	var msg = "{0}丧家之犬，哪里逃！".format([
		DataManager.get_actor_naughty_title(loser.actorId, me.actorId)
	])
	play_dialog(actorId, msg, 0, 2001)
	map.next_shrink_actors = [actorId, loser.actorId]
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20221_3():
	var bf = DataManager.get_current_battle_fight()

	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP)

	map.next_shrink_actors = []
	start_battle_and_finish(actorId, bf.get_loser().actorId)
	return
