extends "effect_20000.gd"

#复勇主动技
#【复勇】大战场,主动技。你可从自身的计策列表中选择一个未禁用的计策，令之直到战争结束前禁用，你的体力恢复“该计策所需机动力”的值。每个回合限3次。

const EFFECT_ID = 20511
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20511_start():
	var items = []
	for scheme in me.get_stratagems():
		items.append("{0}({1})".format([
			scheme.name, scheme.get_cost_ap(actorId),
		]))
	if items.empty():
		play_dialog(actorId, "没有任何可用计策", 3, 2999)
		return
	if actor.get_hp() >= actor.get_max_hp():
		play_dialog(actorId, "并未受伤", 2, 2999)
		return
	SceneManager.show_unconfirm_dialog("禁用哪个计策？", actorId)
	bind_menu_items(items, items, 2)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_item(FLOW_BASE + "_2")
	return

func effect_20511_2():
	var target = DataManager.get_env_str("目标项").split("(")
	var scheme = target[0]
	var ap = Global.intval(target[1].replace(")", ""))
	var msg = "禁用{0}\n回复{1}体力\n可否？".format([
		scheme, ap
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20511_3():
	var target = DataManager.get_env_str("目标项").split("(")
	var scheme = target[0]
	var ap = Global.intval(target[1].replace(")", ""))
	me.dic_skill_cd[scheme] = 99999
	ske.cost_war_limited_times(3)
	ske.change_actor_hp(actorId, ap)
	ske.war_report()

	var msg = "机关算尽，不如奋勇一战！"
	report_skill_result_message(ske, 2002, msg, 0)
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_4")
	return

func effect_20511_4():
	report_skill_result_message(ske, 2002)
	return
