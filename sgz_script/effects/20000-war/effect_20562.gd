extends "effect_20000.gd"

# 八阵* 的觉醒
#【八阵*】大战场，主动技。指定距离6以内的1名敌将，消耗8点机动力发动。概率性对该敌将附加道术 {八阵} 状态。传自武侯，一开始似乎…稍弱。你达到8级，战争中第一次发动命中时，可以消耗10000点经验出师，永久解锁 <八阵>

const EFFECT_ID = 20562
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const ACTIVE_EFFECT_ID = 20005
const COST_EXP = 10000

func on_trigger_20040() -> bool:
	# AI 不发动
	if me.get_controlNo() < 0:
		return false

	# 已经解锁过不发动
	var flag = ske.affair_get_skill_val_int()
	if flag > 0:
		return false

	# 本次战争已经提示选择过，不发动
	var asked = ske.get_war_skill_val_int()
	if asked > 0:
		return false

	# 八级才能发动
	if actor.get_level() < 8:
		return false

	# 经验不足无法发动
	if actor.get_exp() < COST_EXP:
		return false

	# 根据主动技的标记判断是否成功了
	if ske.get_war_skill_val_int(ACTIVE_EFFECT_ID) <= 0:
		return false

	# 标记已经问过了
	ske.set_war_skill_val(1)
	return true

func effect_20562_start() -> void:
	var msg = "武侯所授，今已大成！\n花费 {0} 经验出师\n可否？".format([
		COST_EXP,
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed", false, FLOW_BASE + "_end")
	return

func effect_20562_end() -> void:
	skill_end_clear()
	FlowManager.add_flow("player_ready")
	return

func effect_20562_confirmed() -> void:
	ske.affair_set_skill_val(1)
	ske.change_actor_exp(actorId, -COST_EXP)
	ske.ban_affair_skill(actorId, ske.skill_name, 99999)
	ske.affair_add_skill(actorId, "八阵", 99999)
	ske.war_report()
	report_skill_result_message(ske, 2001)
	return

func on_view_model_2001() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20562_report() -> void:
	report_skill_result_message(ske, 2001)
	return
