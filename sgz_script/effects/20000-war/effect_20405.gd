extends "effect_20000.gd"

#醉卧主动技
#【醉卧】大战场,限定技。你可以将自己转为“醉酒状态”。初次发动时，需要消耗自身10000经验。本技能无法被沉默和夺取。

const EFFECT_ID = 20405
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_EXP = 10000

func effect_20405_start():
	if ske.affair_get_skill_val_int() <= 0:
		if actor.get_exp() < COST_EXP:
			var msg = "经验不足，须 >= {0}".format([COST_EXP])
			SceneManager.show_confirm_dialog(msg)
			LoadControl.set_view_model(2999)
			return

	var msg = "再入醉乡，解锁新技能链\n无需消耗经验，可否？"
	if ske.affair_get_skill_val_int() <= 0:
		msg = "进入醉乡，解锁新技能链\n需消耗{0}经验，可否？"
	msg = msg.format([COST_EXP])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

func effect_20405_2():
	var expCost = 0
	ske.cost_war_cd(99999)
	if ske.affair_get_skill_val_int() <= 0:
		expCost = -actor.add_exp(-COST_EXP)
		ske.append_message("经验减少<r{0}> -> <y{1}>".format([expCost, actor.get_exp()]))
		ske.affair_set_skill_val(1)
	me.set_war_side("醉")
	var wf = DataManager.get_current_war_fight()
	me.dic_other_variable["醉乡"] = wf.date
	ske.append_message("转为<y{0}>面".format([actor.get_side()]))
	ske.war_report()

	var msg = "醉里挑灯……看~剑！"
	if expCost > 0:
		msg += "\n（{0}经验减少{1}\n（现为{2}"
	msg = msg.format([
		actor.get_name(), expCost, actor.get_exp(),
	])
	play_dialog(me.actorId, msg, 1, 2001)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20405_3():
	var msg = "{0}已进入醉乡".format([
		actor.get_name(), actor.get_side(),
	])
	SceneManager.show_actor_info(actor.actorId, true, msg)
	SkillHelper.auto_trigger_skill(actor.actorId, 20013)
	LoadControl.set_view_model(2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return
