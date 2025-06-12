extends "effect_20000.gd"

#智破诱发技 #计策防御
#【智破】大战场，诱发技。你的队友被用计时才能发动。你可以发动：你令对方选择一项：1.需额外消耗3点机动力才能继续计策结算；2.本次计策伤害减半。每回合限3次。

const EFFECT_ID = 20427
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const TIMES_LIMIT = 3
const EXTRA_AP = 3

func on_trigger_20038()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(actorId) < 0:
		return false
	if se.targetId != ske.actorId:
		return false
	if se.targetId == me.actorId:
		# 不可以对自己发动
		return false
	if not se.damage_soldier():
		# 仅伤兵计可发动
		return false
	if ske.get_war_limited_times() >= TIMES_LIMIT:
		# 次数限定
		return false
	return true

func effect_20427_AI_start():
	var se = DataManager.get_current_stratagem_execution()
	se.goback_disabled = 1
	var actioner = DataManager.get_war_actor(se.get_action_id(actorId))
	if actioner.get_controlNo() < 0:
		goto_step("2")
		return
	var msg = "{1}，计将安出？\n（【{2}】发动，请选择：".format([
		DataManager.get_actor_self_title(actorId),
		DataManager.get_actor_naughty_title(actioner.actorId, actorId),
		ske.skill_name
	])
	play_dialog(actorId, msg, 2, 3000, true, ["机动力-3", "减伤50%"])
	return

func on_view_model_3000()->void:
	wait_for_yesno(FLOW_BASE + "_AI_2", false, FLOW_BASE + "_AI_3", false)
	return

func effect_20427_AI_2():
	var se = DataManager.get_current_stratagem_execution()
	var actioner = DataManager.get_war_actor(se.get_action_id(actorId))
	if actioner.action_point < EXTRA_AP:
		var msg = "机动力不足，需 >= {0}".format([EXTRA_AP])
		play_dialog(actioner.actorId, msg, 3, 3001)
		return
	ske.cost_war_limited_times(TIMES_LIMIT)
	ske.change_actor_ap(actioner.actorId, -EXTRA_AP)
	ske.war_report()
	var msg = "额外消耗 {0} 机动力\n现为 {1}".format([EXTRA_AP, actioner.action_point])
	play_dialog(actioner.actorId, msg, 3, 3002)
	return

func on_view_model_3001()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_AI_3")
	return

func on_view_model_3002()->void:
	wait_for_skill_result_confirmation("")
	return

func effect_20427_AI_3():
	ske.cost_war_limited_times(TIMES_LIMIT)
	DataManager.set_env("计策.ONCE.智破", actorId)
	skill_end_clear()
	return

func effect_20427_start():
	var times = ske.get_war_limited_times()
	if times >= TIMES_LIMIT:
		back_to_induce_ready()
		return
	var se = DataManager.get_current_stratagem_execution()
	var actioner = DataManager.get_war_actor(se.get_action_id(actorId))
	var msg = "是否发动【{0}】\n干扰{1}的计策？\n剩余次数: {2}".format([
		ske.skill_name, actioner.get_name(), TIMES_LIMIT - times
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2", false)
	return

func effect_20427_2():
	var se = DataManager.get_current_stratagem_execution()
	var actioner = DataManager.get_war_actor(se.get_action_id(actorId))
	ske.cost_war_limited_times(TIMES_LIMIT)
	# AI 随机选择
	var choice = Global.get_random(0, 1)
	if choice == 0 and actioner.action_point >= EXTRA_AP:
		ske.change_actor_ap(actioner.actorId, EXTRA_AP)
		var msg = "{0}选择额外消耗{1}机动力".format([
			actioner.get_name(), EXTRA_AP,
		])
		ske.war_report()
		play_dialog(actorId, msg, 2, 2001)
		return
	DataManager.set_env("计策.ONCE.智破", actorId)
	var msg = "{0}选择计策伤害减半".format([
		actioner.get_name()
	])
	play_dialog(actorId, msg, 2, 2001)
	return

func on_view_model_2001()->void:
	wait_for_skill_result_confirmation("")
	return
