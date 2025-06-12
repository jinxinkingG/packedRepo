extends "effect_20000.gd"

#醉乡主动技部分
#【醉乡】大战场,主动技。你视为拥有<酒步>；你处于 {定止} 状态时，可以通过主动发动本技能，消耗6点机动力解除自身 {定止} 状态

const EFFECT_ID = 20408
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 6

func effect_20408_start():
	if me.get_buff("定止")["回合数"] <= 0:
		play_dialog(me.actorId, "未被定止，无须发动", 1, 2999)
		return
	if not assert_action_point(me.actorId, COST_AP):
		return

	var msg = "解除定止状态\n消耗{0}机动力，可否？".format([COST_AP])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

func effect_20408_2():
	ske.cost_ap(COST_AP)
	ske.remove_war_buff(me.actorId, "定止")
	ske.war_report()

	var msg = "形虽朦胧，意实不羁\n谁能拘吾于一隅？\n（{0}摆脱[定止]".format([me.get_name()])
	play_dialog(me.actorId, msg, 1, 2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return
