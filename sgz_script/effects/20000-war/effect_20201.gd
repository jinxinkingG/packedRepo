extends "effect_20000.gd"

#看破效果 #计策防御
#【看破】大战场,诱发技。你方武将被用伤兵计的场合，可以发动：你替代该武将进入命中率计算。每回合限3次。

const EFFECT_ID = 20201
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const TIMES_LIMIT = 3

func on_trigger_20038()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.targetId != ske.actorId:
		return false
	if se.targetId == me.actorId:
		# 不可以对自己发动
		return false
	if se.rate_flag != 0:
		# 已经设置必中
		return false
	if not se.damage_soldier():
		# 仅伤兵计可发动
		return false
	if ske.get_war_limited_times() >= TIMES_LIMIT:
		# 次数限定
		return false
	return true

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2", false)
	return

func on_view_model_3000():
	wait_for_pending_message(FLOW_BASE + "_AI_2", "")
	return

func effect_20201_AI_start():
	var se = DataManager.get_current_stratagem_execution()
	se.goback_disabled = 1
	ske.cost_war_limited_times(TIMES_LIMIT)
	se.set_replaced_defender(me.actorId, ske.skill_name)
	se.set_must_fail(me.actorId, ske.skill_name)
	var msg = "敌策并非无懈可击！"
	report_skill_result_message(ske, 3000, msg, 0)
	return

func effect_20201_AI_2():
	report_skill_result_message(ske, 3000)
	return

func effect_20201_start():
	var times = ske.get_war_limited_times()
	if times >= TIMES_LIMIT:
		back_to_induce_ready()
		return
	var se = DataManager.get_current_stratagem_execution()
	var msg = "是否发动【看破】\n替代{0}被用计？\n剩余次数: {1}".format([
		ActorHelper.actor(se.targetId).get_name(), TIMES_LIMIT - times
	])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func effect_20201_2():
	var se = DataManager.get_current_stratagem_execution()

	ske.cost_war_limited_times(TIMES_LIMIT)
	se.set_replaced_defender(me.actorId, ske.skill_name)
	se.set_must_fail(me.actorId, ske.skill_name)
	ske.war_report()
	LoadControl.end_script()
	return
