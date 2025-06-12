extends "effect_20000.gd"

#随医主动技 #施加状态
#【随医】大战场，主动技。你可以消耗10金，获得3回合“愈合”状态。每5个回合限1次。（愈合：良性状态：每日你的体+5，直到恢复至体力上限。）

const EFFECT_ID = 20317
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_GOLD = 10

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_pending_message(FLOW_BASE + "_3")
	return

func effect_20317_start():
	var wv = me.war_vstate()
	if wv.money < COST_GOLD:
		var msg = "金不足，需 >= {0}".format([COST_GOLD])
		play_dialog(me.actorId, msg, 3, 2001)
		return
	var msg = "花费{0}金\n获得[愈合]状态\n可否？".format([
		COST_GOLD
	])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func effect_20317_2():
	ske.cost_war_cd(5)
	ske.cost_wv_gold(COST_GOLD)
	ske.set_war_buff(ske.skill_actorId, "愈合", 3)

	var msg = "稍作医治，回复尚需时日"
	if not actor.is_injured():
		msg = "刀剑无眼，须得未雨绸缪"
	report_skill_result_message(ske, 2001, msg, 1)
	return

func effect_20317_3():
	report_skill_result_message(ske, 2001)
	return
