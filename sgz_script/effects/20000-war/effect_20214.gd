extends "effect_20000.gd"

#就计锁定技 #计伤
#【就计】大战场，锁定技。敌方武将使用计策失败时，你对之结算一次“要击”伤害。同一回合，每名敌将至多触发1次。

const EFFECT_ID = 20214
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const STRATAGEM = "要击"

func on_trigger_20012() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.targetId != ske.actorId:
		return false
	if se.succeeded > 0:
		return false
	var fromId = se.get_action_id(actorId)
	if fromId < 0:
		return false
	var fromWA = DataManager.get_war_actor(fromId)
	if fromWA == null or fromWA.disabled:
		return false
	if fromWA.get_soldiers() <= 0:
		return false
	if fromId in _get_triggered_actors(actorId):
		return false
	DataManager.set_env(_get_target_key(), fromId)
	return true

func effect_20214_AI_start():
	goto_step("start")
	return

func effect_20214_start():
	var targetId = DataManager.get_env_int(_get_target_key())
	_set_triggered_actor(actorId, targetId)
	var se = DataManager.new_stratagem_execution(actorId, STRATAGEM, ske.skill_name)
	se.skip_redo = 1
	se.work_as_skill = 1
	se.set_target(targetId)
	se.perform_to_targets([se.targetId], true)
	se.report()

	DataManager.unset_env(_get_target_key())

	var msg = "敌计何其拙劣\n将计就计，反制{0}！".format([
		ActorHelper.actor(targetId).get_name()
	])
	ske.play_se_animation(se, 2000, msg, 0)
	return

func on_view_model_2000() -> void:
	wait_for_pending_message(FLOW_BASE + "_report", "")
	return

func effect_20214_report() -> void:
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 2000)
	return

func _get_triggered_actors(actorId:int) -> Array:
	return ske.get_war_skill_val_int_array()

func _set_triggered_actor(actorId:int, targetId:int) -> bool:
	var triggered = _get_triggered_actors(actorId)
	if targetId in triggered:
		return false
	triggered.append(targetId)
	ske.set_war_skill_val(triggered, 1)
	return true

func _get_target_key()->String:
	return "技能.就计.目标.{0}".format([actorId])
