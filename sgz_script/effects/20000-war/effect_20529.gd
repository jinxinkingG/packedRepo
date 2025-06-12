extends "effect_20000.gd"

#论势主动技
#【论势】大战场，主动技。消耗5机动力，发动后，下一次白刃战中，己方武将的士气至少比对方高1点。每3日限一次。

const EFFECT_ID = 20529
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 5

func effect_20529_start() -> void:
	if not assert_action_point(actorId, COST_AP):
		return
	var msg = "消耗{0}机动力发动【{1}】\n令我军在下一场白刃战中取得优势。可否？".format([
		COST_AP, ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_2")
	return

func effect_20529_2() -> void:
	ske.cost_war_cd(3)
	ske.set_war_skill_val(1)
	ske.war_report()

	var msg = "强弱之分，当见微而知著\n诸公只管列阵\n两军阵前，{0}试为论之".format([
		actor.get_short_name(),
	])
	play_dialog(actorId, msg, 1, 2999)
	return
