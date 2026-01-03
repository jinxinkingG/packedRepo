extends "effect_20000.gd"

#冷箭主动技 #施加状态 #机动力上限
#【冷箭】大战场，限定技。你选择一个对方武将（非太守府），减少你5点机动力上限，对其发射带毒的冷箭，使其附带8回合 {中毒} 状态。

const EFFECT_ID = 20282
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_MAX_AP = 5
const BUFF_TURNS = 8

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_4")
	return

func effect_20282_start():
	var targets = []
	for targetId in get_enemy_targets(me, true):
		var wa = DataManager.get_war_actor(targetId)
		var block = map.get_blockCN_by_position(wa.position)
		if block in ["太守府"]:
			continue
		targets.append(targetId)
	if not wait_choose_actors(targets, "选择敌军发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20282_2():
	var targetId = get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var msg = "机动力上限-{0}\n对{1}发动【{2}】，使其中毒，可否？".format([
		COST_MAX_AP, targetActor.get_name(), ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func effect_20282_3():
	var targetId = get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var targetActor = ActorHelper.actor(targetId)

	ske.cost_war_cd(99999)
	ske.set_actor_extra_ap_limit(actorId, -COST_MAX_AP)
	ske.set_war_buff(targetId, "中毒", BUFF_TURNS)

	var msg = "{0}休得张狂，看箭！".format([
		DataManager.get_actor_naughty_title(targetId, self.actorId),
	])
	report_skill_result_message(ske, 2002, msg, 0)
	return

func effect_20282_4():
	report_skill_result_message(ske, 2002)
	return
