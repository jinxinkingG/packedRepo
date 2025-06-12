extends "effect_20000.gd"

#强行主动技 #机动力
#【强行】大战场，主动技。你方金-100，你的机动力+6，每回合限1次

const EFFECT_ID = 20370
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_GOLD = 100
const AP_RECOVER = 6

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

func on_view_model_2009():
	wait_for_skill_result_confirmation()
	return

func check_AI_perform_20000()->bool:
	var wv = me.war_vstate()
	if wv == null or wv.money < 1000:
		return false
	# 金足够，看看周围有没有人
	if get_enemy_targets(me).empty():
		return false
	# 随机发动
	if Global.get_rate_result(50):
		return true
	# 不发动就明天再说
	ske.cost_war_cd(1)
	return false

func effect_20370_AI_start():
	goto_step("2")
	return

func effect_20370_start():
	var wv = me.war_vstate()
	if wv == null or wv.money < COST_GOLD:
		var msg = "金不足，须 >= {0}".format([COST_GOLD])
		play_dialog(me.actorId, msg, 3, 2009)
		return
	var msg = "消耗{0}金发动【{1}】\n回复{2}机动力\n可否？".format([
		COST_GOLD, ske.skill_name, AP_RECOVER,
	])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func effect_20370_2():
	ske.cost_war_cd(1)
	ske.cost_wv_gold(COST_GOLD)
	ske.change_actor_ap(me.actorId, AP_RECOVER)
	ske.war_report()
	
	var msg = "战酣矣，敌安得不疲？\n重赏士卒，强行军！\n（机动力回复{0}".format([
		AP_RECOVER
	])
	play_dialog(me.actorId, msg, 0, 2009)
	return

