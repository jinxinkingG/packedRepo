extends "effect_20000.gd"

#击免主动技
#【击免】大战场，主动技。消耗10机动力，发动后，直到次回合前，你无法被选为攻击目标。每3日限1次。

const EFFECT_ID = 20557
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 10

func effect_20557_start() -> void:
	if not assert_action_point(actorId, COST_AP):
		return
	var msg = "消耗 {0} 机动力\n发动【{1}】，免于被攻击\n可否？".format([
		COST_AP, ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_2")
	return

func effect_20557_2() -> void:
	ske.cost_ap(COST_AP, true)
	ske.cost_war_cd(3)
	ske.set_war_skill_val(1, 2)
	ske.war_report()
	var msg = "遵时养晦，待机而动"
	play_dialog(actorId, msg, 2, 2999)
	return
