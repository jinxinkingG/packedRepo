extends "effect_20000.gd"

#延祸限定技部分
#【延祸】大战场，主将限定技。敌方所有武将技能，直到本回合结束前禁用，你方所有武将机动力+5，并获得 {围困} 状态，持续到战争结束；该回合结束后，你方所有武将的技能直到战争结束前禁用。

const EFFECT_ID = 20461
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20461_start():
	var msg = "发动【{0}】，殊死一搏\n可否？".format([ske.skill_name])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2", true)
	return

func effect_20461_2():
	ske.set_war_skill_val(1, 99999)
	ske.cost_war_cd(99999)
	ske.change_actor_ap(actorId, 5)
	ske.set_war_buff(actorId, "围困", 30)
	for targetId in get_teammate_targets(me, 999):
		ske.change_actor_ap(targetId, 5)
		ske.set_war_buff(targetId, "围困", 30)
	for targetId in get_enemy_targets(me, true, 999):
		ske.set_war_buff(targetId, "沉默", 1)
	ske.war_report()
	var msg = "事急矣，两害相权，不得不为！\n（发动【{0}，全体机动力 +5\n（敌军技能本回合禁用\n（我军全体获得「围困」".format([
		ske.skill_name
	])
	play_dialog(me.actorId, msg, 0, 2001)
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation()
	return
