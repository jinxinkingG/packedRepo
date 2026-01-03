extends "effect_20000.gd"

#智愚锁定效果及对话触发
#【智愚】大战场，锁定技。你每回合第一次伤兵类计策失败时，也可造成原伤害*命中率的伤害

const EFFECT_ID = 20031
const FLOW_BASE = "effect_" + str(EFFECT_ID)

#写入计策伤兵量前（用计者触发）
func on_trigger_20011()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.skill != ske.skill_name:
		return false
	var rate = ske.get_war_skill_val_int()
	if rate <= 0:
		return false
	ske.set_war_skill_val(0, 0)
	ske.cost_war_cd(1)
	var damage = DataManager.get_env_int("计策.ONCE.伤害")
	damage = int(ceil(damage * rate / 100.0))
	DataManager.set_env("计策.ONCE.伤害", damage)
	var msg = "【{0}】强制造成{1}%伤害".format([ske.skill_name, rate])
	se.append_result(ske.skill_name, msg, rate, me.actorId)
	return false

#计策结束时（有flow）
func on_trigger_20012()->bool:
	ske.set_war_skill_val(0, 0)
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(me.actorId) != me.actorId:
		# 必须自己
		return false
	if se.succeeded > 0:
		# 用计成功时跳过
		return false
	if not se.damage_soldier():
		#非伤兵计跳过
		return false
	if se.rate <= 0:
		return false
	# AI 连续计策期间，se 可能会被冲掉，所以用变量记录
	ske.set_war_skill_val(se.rate, 1)
	return true

func effect_20031_AI_start() -> void:
	goto_step("start")
	return

func effect_20031_start() -> void:
	var se = DataManager.get_current_stratagem_execution()
	var targetId = se.targetId
	var skillInfo = "- <y{0}>计策失败，触发<r【{1}】>".format([
		actor.get_name(), ske.skill_name,
	])
	DataManager.record_war_log(skillInfo)
	se = DataManager.new_stratagem_execution(me.actorId, se.name, ske.skill_name)
	se.set_target(targetId)
	se.rate = ske.get_war_skill_val_int()
	se.perform_to_targets([se.targetId], true)
	var msg = "愚者千虑，必有一得!"
	play_dialog(actorId, msg, 2, 2000)
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_report")
	return

func effect_20031_report() -> void:
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 2001)
	return

func on_view_model_2001():
	wait_for_pending_message(FLOW_BASE + "_report", "")
	return
