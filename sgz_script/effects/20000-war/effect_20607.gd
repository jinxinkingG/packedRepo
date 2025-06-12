extends "effect_20000.gd"

# 密信限定技
#【密信】大战场，限定技。你为攻城方，你指定1名忠<70的敌将才能发动。视为你对之使用计策「笼络」。

const EFFECT_ID = 20607
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20607_start() -> void:
	var targetIds = []
	for targetId in get_enemy_targets(me):
		if ActorHelper.actor(targetId).get_loyalty() >= 70:
			continue
		targetIds.append(targetId)
	if targetIds.empty():
		var msg = "没有可以发动【{0}】的目标".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return
	if not wait_choose_actors(targetIds):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20607_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var msg = "{0}或可说之\n对其发动【{1}】\n可否？".format([
		ActorHelper.actor(targetId).get_name(),
		ske.skill_name
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20607_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	var se = DataManager.new_stratagem_execution(actorId, "笼络", ske.skill_name)
	se.set_target(targetId)
	se.perform_to_targets([targetId])
	se.report()
	
	ske.cost_war_cd(99999)
	ske.set_war_skill_val([se.targetId, se.succeeded])
	ske.war_report()

	ske.play_se_animation(se, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20607_report() -> void:
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 2002)
	return
