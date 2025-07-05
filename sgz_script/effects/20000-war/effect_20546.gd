extends "effect_20000.gd"

#傀权锁定技
#【傀权】大战场，主将锁定技。回合开始时，若你不是己方在场唯一的武将，你必须消耗所有机动力，并选择一名队友为目标发动：由自身转移给该队友300兵力

const EFFECT_ID = 20546
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const TRANSFER = 300

func on_trigger_20013() -> bool:
	if me.actor().get_soldiers() == 0:
		return false
	if get_targets().empty():
		return false
	return true

func effect_20546_start() -> void:
	var msg = "泥偶木雕，愧对先祖\n……"
	play_dialog(actorId, msg, 3, 2000)
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_20546_2() -> void:
	var msg = "兵力转给何人？"
	if not wait_choose_actors(get_targets(), msg, true):
		return
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001() -> void:
	wait_for_choose_actor(FLOW_BASE + "_3", false, false)
	return

func effect_20546_3() -> void:
	var targetId = DataManager.get_env_int("目标")
	var transfer = ske.sub_actor_soldiers(actorId, TRANSFER)
	ske.add_actor_soldiers(targetId, transfer, 2500)
	ske.cost_ap(me.action_point)
	ske.war_report()
	goto_step("report")
	return

func effect_20546_report() -> void:
	report_skill_result_message(ske, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func get_targets() -> PoolIntArray:
	var ret = []
	for wa in me.war_vstate().get_war_actors(false, true):
		if wa.actorId == me.actorId:
			continue
		if wa.actor().get_soldiers() >= 2500:
			continue
		ret.append(wa.actorId)
	return ret
