extends "effect_20000.gd"

# 思慎诱发技
#【思慎】大战场，诱发技。你方武将用计失败时才能发动。使之恢复那次计策消耗的全部机动力。这个技能名的效果每回合限1次。

const EFFECT_ID = 20719
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20012() -> bool:
	# 检查计策执行情况
	var se = DataManager.get_current_stratagem_execution()

	# 计策成功不触发（与曲顾判断一致）
	if se.succeeded > 0:
		return false

	# 检查计策消耗
	if se.cost <= 0:
		return false

	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null:
		return false

	# 检查是否已经使用过（同方所有人的同名技能都不能重复使用）
	var key = "COMMONCD.{0}.{1}.{2}".format([
		ske.skill_name, wf.date, me.vstate().id
	])
	if wf.get_env_int(key) > 0:
		return false

	return true

func effect_20719_AI_start() -> void:
	# AI自动发动
	goto_step("recover")
	return

func effect_20719_start() -> void:
	var se = DataManager.get_current_stratagem_execution()
	var wa = DataManager.get_war_actor(ske.actorId)

	var msg = "发动【{0}】\n为{1}恢复 {2}机动力\n可否？".format([
		ske.skill_name, wa.get_name(), se.cost
	])
	play_dialog(actorId, msg, 0, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_recover")
	return

func effect_20719_recover() -> void:
	# 设置技能CD（每回合限1次）
	ske.cost_war_cd(1)
	# 同时设置全局标记
	var key = "COMMONCD.{0}.{1}.{2}".format([
		ske.skill_name, wf.date, me.vstate().id
	])
	wf.set_env(key, 1)

	# 获取计策消耗的机动力
	var se = DataManager.get_current_stratagem_execution()
	var wa = DataManager.get_war_actor(ske.actorId)

	# 打断连策
	se.skip_redo = 1

	# 恢复机动力
	var ap = se.cost
	ap = ske.change_actor_ap(wa.actorId, ap)
	ske.war_report()

	var msg = "失策事小\n熟思慎行，不为失机"
	if ske.actorId != actorId:
		msg = "{0}勿忧，" + msg
	msg = msg.format([
		DataManager.get_actor_honored_title(wa.actorId, actorId),
		wa.get_name(), ap,
	])
	report_skill_result_message(ske, 2001, msg, 1, actorId)
	return

func on_view_model_2001() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20719_report() -> void:
	report_skill_result_message(ske, 2001)
	return
