extends "effect_20000.gd"

#急攻限定技实现
#【急攻】大战场，限定技。发动后你立刻增加15点机动力。下个回合开始时，你可恢复的机动力为X（X=发动回合你对敌将造成的兵力伤害÷100。最大不超过25）。

const EFFECT_ID = 20320
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const AP_GAIN = 15

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation()
	return

func effect_20320_start():
	var msg = "发动【{0}】，获得{1}机动力，下回合机动力回复将取决于战果，可否？".format([
		ske.skill_name, AP_GAIN,
	])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func effect_20320_2():
	ske.cost_war_cd(99999)
	var ap = ske.change_actor_ap(me.actorId, AP_GAIN)
	ske.set_war_skill_val(1, 99999)
	ske.war_report()
	var msg = "建功立业，正在今日！\n（机动力+{0}，现为{1}".format([
		ap, me.action_point,
	])
	play_dialog(me.actorId, msg, 0, 2001)
	return
