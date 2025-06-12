extends "effect_20000.gd"

#引诱主动技
#【引诱】大战场，主动技。发动后的下个对方回合结束时，在你周围X格距离内的所有敌将（非城地形），尽可能地向你所在位置移动，至多移动3格。X=你的等级/2，每3个回合限一次

const EFFECT_ID = 20043
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const PASSIVE_EFFECT_ID = 20044

func effect_20043_start():
	var x = int(actor.get_level() / 2)
	var msg = "以身诱敌。{0}格以内的敌军\n行动结束后将向我靠拢\n可否？".format([x])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

func effect_20043_2():
	ske.set_war_skill_val(1, 1, PASSIVE_EFFECT_ID)
	ske.cost_war_cd(3)
	ske.set_war_buff(actorId, "诱敌", 1)
	ske.war_report()
	var msg = "不入虎穴，焉得虎子！"
	play_dialog(actorId, msg, 0, 2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return
