extends "effect_20000.gd"

# 业炎和烬灭锁定技
#【业炎】大战场,锁定技。你使用单体伤兵计成功时，对目标额外结算一次50%伤害的「火计*」；你使用群体伤兵计成功时，对目标额外结算一次50%伤害的「劫火*」。
#【烬灭】大战场,主将锁定技。你的队友使用单体伤兵计成功时，对目标额外结算一次50%伤害的「火计*」；你的队友使用群体伤兵计成功时，对目标额外结算一次50%伤害的「劫火*」。

const EFFECT_ID = 20207
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const DEFAULT_APPENDED_STRATAGEM = "火计*";
const STRATAGEM_DIC = {
	"劫火": "劫火*",
	"水攻": "劫火*",
	"共杀": "劫火*"
}

func on_trigger_20005()->bool:
	var cost = get_env_int("计策.消耗.所需")
	set_scheme_ap_cost("火计", cost - 1)
	set_scheme_ap_cost("火箭", cost - 2)
	set_scheme_ap_cost("劫火", cost - 3)
	return false

func on_trigger_20012()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(actorId) != ske.actorId:
		return false
	if ske.skill_name == "烬灭" and actorId == ske.actorId:
		return false
	if not se.damage_soldier():
		return false
	if se.succeeded <= 0:
		return false
	var targetWA = DataManager.get_war_actor(se.targetId)
	if targetWA == null or targetWA.disabled:
		return false
	if ActorHelper.actor(se.targetId).get_soldiers() <= 0:
		return false
	return true

func effect_20207_AI_start():
	goto_step("start")
	return

func effect_20207_start():
	var se = DataManager.get_current_stratagem_execution()
	var appendedStratagem = DEFAULT_APPENDED_STRATAGEM
	var msg = "蕞尔小丑\n可知业火无情！\n（【{0}】附加{1}"
	if STRATAGEM_DIC.has(se.name):
		appendedStratagem = STRATAGEM_DIC[se.name]
		msg = "任尔强梁\n难逃灰飞湮灭！\n（【{0}】附加{1}"
	msg = msg.format([ske.skill_name, appendedStratagem])
	var targetId = se.targetId
	# 在发动追加计策之前，需要保留现场
	# 否则会影响后续的技能触发和连策执行
	DataManager.save_stratagem_execution("战争.业炎现场")
	se = DataManager.new_stratagem_execution(actorId, appendedStratagem, ske.skill_name)
	se.set_target(targetId)
	se.skip_redo = 1
	se.perform_to_targets([se.targetId], true)
	map.draw_actors()

	ske.play_se_animation(se, 2000, msg, 0)
	return

func on_view_model_2000()->void:
	wait_for_pending_message(FLOW_BASE + "_report", FLOW_BASE + "_end")
	return

func effect_20207_report():
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 2000)
	return

func effect_20207_end():
	# 恢复计策历史，以便连策能继续执行
	DataManager.recover_stratagem_execution("战争.业炎现场")
	skill_end_clear()
	return
