extends "effect_20000.gd"

# 周旋主动技
#【周旋】大战场，主动技。你可指定一名敌将为目标，消耗5点机动力发动。将之设为“旋目标”，持续2回合。仅在这2回合内，你额外附加<策行>。场上存在“旋目标”时，你无法再主动发动本技能。

const EFFECT_ID = 20574
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 5

func effect_20574_start() -> void:
	if not assert_action_point(actorId, COST_AP):
		return
	var targets = []
	if not wait_choose_actors(get_enemy_targets(me)):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20574_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var msg = "消耗 {0} 机动力\n设定{2}为【{1}】目标\n可否？".format([
		COST_AP, ske.skill_name, ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20574_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")

	ske.cost_ap(COST_AP, true)
	ske.cost_war_cd(2)
	ske.set_war_skill_val(targetId, 2)
	ske.add_war_skill(actorId, "策行", 2)
	ske.war_report()

	var msg = "{0}可堪敌手\n且看吾手段！".format([
		DataManager.get_actor_naughty_title(targetId, actorId)
	])
	report_skill_result_message(ske, 2002, msg, 0)
	return

func on_view_model_2002() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20574_report() -> void:
	report_skill_result_message(ske, 2002)
	return
