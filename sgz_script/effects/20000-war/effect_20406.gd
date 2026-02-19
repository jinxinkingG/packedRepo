extends "effect_20000.gd"

#解醒主动技
#【解醒】大战场，锁定技。你转为 {醉乡} 状态的5回合后，转为“正常状态”。本技能不会被沉默、禁用、夺取。


const EFFECT_ID = 20406
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_EXP = 2000

func effect_20406_start():
	var side = actor.get_side()
	if side in ["阴", "阳"]:
		var msg = "未进入醉乡，何须解醒？"
		play_dialog(me.actorId, msg, 2, 2999)
		return
	var msg = "脱离醉乡，恢复技能链\n可否？"
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

func effect_20406_2():
	ske.cost_war_cd(99999)
	var side = actor.get_side()
	me.set_war_side("")
	ske.append_message("解除<y{0}>面".format([side]))
	ske.war_report()

	var msg = "黄粱一梦……\n（{0}已脱离醉乡".format([
		actor.get_name(), side,
	])
	play_dialog(me.actorId, msg, 2, 2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return

func on_trigger_20016()->bool:
	var wf = DataManager.get_current_war_fight()
	var drunkDay = 1
	if me.dic_other_variable.has("醉乡"):
		drunkDay = int(me.dic_other_variable["醉乡"])
	if wf.date < drunkDay + 4:
		return false
	ske.cost_war_cd(99999)
	var side = actor.get_side()
	me.set_war_side("")
	ske.append_message("解除<y{0}>面".format([side]))
	ske.war_report()

	var msg = "黄粱一梦……\n（{0}已脱离醉乡".format([
		actor.get_name(), side,
	])
	me.attach_free_dialog(msg, 2)
	return false
