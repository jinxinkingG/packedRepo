extends "effect_20000.gd"

#深谋效果实现
#【深谋】大战场,诱发技。你使用伤兵/伤体计策时，可多消耗30%机动力（向上取整），若成功，则增加 50% 的计策伤害。

const EFFECT_ID = 20254
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const DAMAGE_RAISE = 50

func on_trigger_20011()->bool:
	var flag = ske.get_war_skill_val_int()
	# 无条件清除标记
	ske.set_war_skill_val(0, 0)
	if flag <= 0:
		return false
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(me.actorId) != me.actorId:
		return false
	change_scheme_damage_rate(DAMAGE_RAISE)
	return false

func on_trigger_20018()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	if se.get_action_id(me.actorId) != me.actorId:
		return false
	var extra = int(ceil(se.cost * 3 / 10.0))
	if me.action_point < se.cost + get_cost_ap():
		return false
	return true

func effect_20254_AI_start():
	var se = DataManager.get_current_stratagem_execution()
	var myInt = ActorHelper.actor(self.actorId).get_wisdom()
	var targetInt = ActorHelper.actor(se.targetId).get_wisdom()
	if myInt - 10 < targetInt:
		LoadControl.end_script()
		return
	goto_step("2")
	return

func effect_20254_start():
	var se = DataManager.get_current_stratagem_execution()
	var extra = int(ceil(se.cost * 3 / 10.0))
	var msg = "消耗{0}机动力发动【{1}】\n若计策成功，加深伤害\n可否？".format([
		extra, ske.skill_name
	])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2", false)
	return

func effect_20254_2():
	var se = DataManager.get_current_stratagem_execution()
	var extra = int(ceil(se.cost * 3 / 10.0))

	ske.cost_ap(extra)
	ske.set_war_skill_val(1, 1)
	se.goback_disabled = 1
	ske.war_report()
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

func on_view_model_2001():
	wait_for_skill_result_confirmation("")
	return

func get_cost_ap()->int:
	var se = DataManager.get_current_stratagem_execution()
	var extra = int(ceil(se.cost * 3 / 10.0))
	return extra
