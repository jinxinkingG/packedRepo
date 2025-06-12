extends "effect_20000.gd"

# 怀仁主动技
#【怀仁】大战场，限定技。发动后，在场所有将领获得<藏祸>，并在3日内处于 {罢兵} 状态。

const EFFECT_ID = 20587
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const TARGET_SKILL = "藏祸"

func effect_20587_start() -> void:
	var msg = "发动【{0}】\n所有人获得【{1}】\n三日内按兵不动，可否？".format([
		ske.skill_name, TARGET_SKILL,
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20587_confirmed() -> void:
	var msg = "兵者不祥之器，诸公听我一言\n罢兵三日，殓丧葬殁，略养生息\n如何？"
	play_dialog(actorId, msg, 2, 2001)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_deal")
	return

func effect_20587_deal() -> void:
	var leader = me.get_enemy_leader()
	var msg = "既如此，从{0}所言".format([
		DataManager.get_actor_honored_title(actorId, leader.actorId)
	])
	play_dialog(leader.actorId, msg, 2, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_report")
	return

func effect_20587_report() -> void:
	var wf = DataManager.get_current_war_fight()
	for wa in wf.get_war_actors(false):
		ske.add_war_skill(wa.actorId, TARGET_SKILL, 99999)
		ske.set_war_buff(wa.actorId, "罢兵", 3)
	ske.cost_war_cd(99999)
	ske.war_report()

	var msg = "众人解锁【{0}】\n进入 [罢兵] 状态三日".format([
		TARGET_SKILL,
	])
	play_dialog(-1, msg, 2, 2999)
	return
