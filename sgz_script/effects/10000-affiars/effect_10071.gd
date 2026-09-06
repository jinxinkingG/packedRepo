extends "effect_10000.gd"

#丹转主动技-内政
#【丹转】内政&大战场，主动技。经验＞500，才能使用。使用后，你的经验-500，你的知武互换，政统互换。内政每月限1次；大战场每回合限1次。

const EFFECT_ID = 10071
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_EXP = 500

func effect_10071_start() -> void:
	if actor.get_exp() <= COST_EXP:
		var msg = "经验不足，须 > {0}".format([COST_EXP])
		play_dialog(actorId, msg, 3, 2999)
		return

	var msg = "知、武互换\n政、统互换\n需消耗{0}经验，可否？".format([COST_EXP])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_10071_confirmed() -> void:
	ske.affair_cd(1)
	actor.set_exp(actor.get_exp() - COST_EXP)

	for swaping in [["知", "武"], ["统", "政"]]:
		var current = actor._get_attr_int(swaping[0])
		actor._set_attr_int(swaping[0], actor._get_attr_int(swaping[1]))
		actor._set_attr_int(swaping[1], current)
	
	var msg = "丹转如意，妙法自然\n（经验减少{0}\n（现为{1}".format([
		COST_EXP, actor.get_exp(),
	])
	play_dialog(actorId, msg, 1, 2001)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_done")
	return

func effect_10071_done() -> void:
	SceneManager.show_actor_info(actor.actorId, true, "功行圆满，属性转换完成")
	LoadControl.set_view_model(2999)
	return
