extends "effect_20000.gd"

# 警叛诱发技
#【警叛】大战场，诱发技。你方武将被笼络成功时，你可以发动：选择一个己方武将与背叛者进入白刃战，且己方武将的士气+10，战术值+10

const EFFECT_ID = 20326
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20012() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(actorId) != ske.actorId:
		return false
	if se.name != "笼络":
		return false
	if se.succeeded <= 0:
		return false
	if check_combat_targets([se.targetId]).empty():
		return false
	se.report()
	DataManager.set_env("技能.警判.目标", se.targetId)
	return true

func effect_20326_AI_start() -> void:
	DataManager.set_env("目标", actorId)
	goto_step("3")
	return

func effect_20326_start() -> void:
	var targetId = DataManager.get_env_int("技能.警判.目标")
	var me = DataManager.get_war_actor(self.actorId)
	var targets = get_teammate_targets(me)
	targets.append(actorId)
	targets = check_combat_targets(targets)
	if not wait_choose_actors(targets, "选择己方武将发动【警判】"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_2", false)
	return

func effect_20326_2() -> void:
	var fromId = DataManager.get_env_int("目标")
	var targetId = DataManager.get_env_int("技能.警判.目标")
	var msg = "发动【警判】\n令{0}攻击{1}\n可否？"
	if fromId == actorId:
		msg = "发动【警判】\n攻击{1}\n可否？"
	msg = msg.format([
		ActorHelper.actor(fromId).get_name(),
		ActorHelper.actor(targetId).get_name()
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_3", false)
	return

func effect_20326_3() -> void:
	var fromId = DataManager.get_env_int("目标")
	DataManager.set_env("技能.警判.武将", fromId)
	var targetId = DataManager.get_env_int("技能.警判.目标")
	var msg = "可恨{0}！反复无常！".format([
		DataManager.get_actor_naughty_title(targetId, actorId),
	])
	if fromId == actorId:
		msg += "\n待吾自讨之！"
	else:
		msg += "\n烦请{0}讨之！".format([
			DataManager.get_actor_honored_title(fromId, actorId)
		])
	play_dialog(actorId, msg, 0, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_20326_4() -> void:
	var fromId = DataManager.get_env_int("技能.警判.武将")
	var targetId = DataManager.get_env_int("技能.警判.目标")
	DataManager.unset_env("技能.警判.武将")
	DataManager.unset_env("技能.警判.目标")
	inc_skill_triggered_times(fromId, EFFECT_ID, 20000)
	start_battle_and_finish(fromId, targetId)
	return
