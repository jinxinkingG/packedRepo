extends "effect_20000.gd"

#远虑效果实现
#【远虑】大战场,诱发技。你使用伤兵类计策时，可以多消耗2点机动力，视为与对方距离为1。

const EFFECT_ID = 20360
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 2

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2", false)
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation("")
	return

func effect_20360_AI_start():
	var se = DataManager.get_current_stratagem_execution()
	var target = DataManager.get_war_actor(se.targetId)
	if target == null:
		LoadControl.end_script()
		return
	var disv = target.position - me.position
	if max(abs(disv.x), abs(disv.y)) <= 3:
		LoadControl.end_script()
		return
	goto_step("2")
	return

func effect_20360_start():
	var msg = "消耗{0}机动力发动【{1}】\n与目标的距离视为1\n可否？".format([
		COST_AP, ske.skill_name
	])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func effect_20360_2():
	var se = DataManager.get_current_stratagem_execution()

	ske.cost_ap(COST_AP)
	ske.war_report()
	se.goback_disabled = 1
	se.set_fixed_distance(1, ske)

	if me.get_controlNo() < 0:
		# AI 无计策发动信息，播放念白
		var msg = "明察而众和，谋深而虑远\n（{0}发动【{1}】".format([
			me.get_name(), ske.skill_name,
		])
		play_dialog(me.actorId, msg, 2, 2001)
		return
	# player 有计策发动信息，追加信息
	se.message = "明察而众和，谋深而虑远\n" + se.get_message()
	LoadControl.end_script()
	return

func on_trigger_20018()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	if se.get_action_id(me.actorId) != me.actorId:
		return false
	if me.action_point < se.stratagem.get_cost_ap(me.actorId) + COST_AP:
		return false
	var target = DataManager.get_war_actor(se.targetId)
	if target == null:
		return false
	var disv = target.position - me.position
	return max(abs(disv.x), abs(disv.y)) > 1
