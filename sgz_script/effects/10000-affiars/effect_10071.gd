extends "effect_10000.gd"

#丹转主动技
#【丹转】内政，主动技。经验＞2000，才能使用。使用后，你的经验-2000，你的知武互换，政统互换。

const EFFECT_ID = 10071
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_EXP = 2000


func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func on_view_model_2009():
	wait_for_skill_result_confirmation()
	return

func effect_10071_start():
	if actor.get_exp() < COST_EXP:
		var msg = "经验不足，须 >= {0}".format([COST_EXP])
		SceneManager.show_confirm_dialog(msg)
		LoadControl.set_view_model(2009)
		return

	var msg = "知、武互换\n政、统互换\n需消耗{0}经验，可否？".format([COST_EXP])
	SceneManager.show_yn_dialog(msg, actor.actorId)
	LoadControl.set_view_model(2000)
	return

func effect_10071_2():
	ske.affair_cd(1)
	actor.set_exp(actor.get_exp() - COST_EXP)

	for swaping in [["知", "武"], ["统", "政"]]:
		var current = actor._get_attr_int(swaping[0])
		actor._set_attr_int(swaping[0], actor._get_attr_int(swaping[1]))
		actor._set_attr_int(swaping[1], current)
	
	var msg = "丹转如意，妙法自然\n（{0}的经验减少{1}\n现为{2}".format([
		actor.get_name(), COST_EXP, actor.get_exp(),
	])
	SceneManager.show_confirm_dialog(msg, actor.actorId, 1)
	LoadControl.set_view_model(2001)
	return

func effect_10071_3():
	SceneManager.show_actor_info(actor.actorId, true, "功行圆满，属性转换完成")
	LoadControl.set_view_model(2009)
	return
