extends "effect_20000.gd"

#撒豆主动技 #回复兵力
#【撒豆】大战场,主动技。天数为奇数时，你可以启用道术：消耗任意数量的米（至少1）增加自身兵力，每消耗1石米，你的兵力增加3人。战争结束后，豆兵自动消散。

const EFFECT_ID = 20163
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000():
	wait_for_number_input(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_pending_message(FLOW_BASE + "_3")
	return

func on_view_model_2009():
	wait_for_skill_result_confirmation()
	return

func effect_20163_start():
	var wv = me.war_vstate()
	if wv.rice <= 0:
		var msg = "米已尽矣"
		play_dialog(me.actorId, msg, 3, 2009)
		return

	var maxAmount = int(ceil((2500 - actor.get_soldiers()) / 3.0))
	maxAmount = min(wv.rice, maxAmount)
	if maxAmount <= 0:
		var msg = "今士兵足用\n当堂堂正正而战"
		play_dialog(me.actorId, msg, 2, 2009)
		return
	SceneManager.show_input_numbers("每1米可换3兵，消耗多少米？",["米"],[maxAmount],[0],[3])
	SceneManager.input_numbers.show_actor(actorId)

	LoadControl.set_view_model(2000)
	return

func effect_20163_2():
	var cost = get_env_int("数值")

	ske.cost_war_cd(1)
	ske.cost_wv_rice(cost)
	ske.add_war_tmp_soldier(ske.skill_actorId, cost * 3, 2500)

	var msg = "剪草为马，撒豆成兵！"
	report_skill_result_message(ske, 2001, msg, 0)
	return

func effect_20163_3():
	report_skill_result_message(ske, 2001)
	return
