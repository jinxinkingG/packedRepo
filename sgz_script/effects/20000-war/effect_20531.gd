extends "effect_20000.gd"

#求计主动技
#【求计】大战场，限定技。指定1名队友，你获得其全部机动力，这个效果发动的回合，你可无视定止移动，但不能进行用计和攻击。

const EFFECT_ID = 20531
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20531_start() -> void:
	var targets = []
	for targetId in get_teammate_targets(me):
		var wa = DataManager.get_war_actor(targetId)
		if wa.action_point <= 0:
			continue
		targets.append(targetId)
	if targets.empty():
		var msg = "无人可求"
		play_dialog(actorId, msg, 3, 2999)
		return
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20531_2() -> void:
	var targetId = DataManager.get_env_int("目标")
	var msg = "向{0}【{1}】\n获得其全部机动力\n可否？".format([
		ActorHelper.actor(targetId).get_name(), ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20531_3() -> void:
	var targetId = DataManager.get_env_int("目标")

	var msg = "{0}部危在旦夕\n{1}忍无一策相救乎？".format([
		actor.get_short_name(),
		DataManager.get_actor_honored_title(targetId, actorId)
	])
	play_dialog(actorId, msg, 3, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_20531_4() -> void:
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)
	var ap = wa.action_point

	ske.cost_war_cd(99999)
	ske.change_actor_ap(actorId, ap)
	ske.change_actor_ap(targetId, -ap)
	me.set_tmp_variable("无视定止", 1)
	ske.append_message("本回合可无视定止移动")
	ske.set_war_buff(actorId, "禁兵", 1)
	ske.set_war_buff(actorId, "禁策", 1)
	ske.war_report()

	var msg = "{0}不可自蹈死地\n当速行".format([
		DataManager.get_actor_honored_title(actorId, targetId),
	])
	report_skill_result_message(ske, 2003, msg, 2, targetId)
	return

func effect_20531_report() -> void:
	report_skill_result_message(ske, 2003)
	return

func on_view_model_2003() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return
