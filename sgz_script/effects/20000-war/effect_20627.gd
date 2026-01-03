extends "effect_20000.gd"

# 佯焚主动技
#【佯焚】大战场，主动技。你指定一个符合地形要求的敌军，假意发动「火计」，不造成任何伤害，但令敌军随机移动一步。每回合限1次。

const EFFECT_ID = 20627
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func check_AI_perform_20000() -> bool:
	var targetIds = _get_available_targets()
	return not targetIds.empty()

func effect_20627_AI_start() -> void:
	var targetIds = Array(_get_available_targets())
	targetIds.shuffle()
	DataManager.set_env("目标", targetIds[0])
	goto_step("confirmed")
	return

func effect_20627_start() -> void:
	var se = DataManager.new_stratagem_execution(actorId, "火计")
	var ret = se.get_available_targets()
	var targetIds = ret[0]
	for targetId in ret[1]:
		targetIds.erase(targetId)
	if targetIds.empty():
		var msg = "没有可以发动【{0}】的目标".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return
	var msg = "选择【{0}】目标".format([ske.skill_name])
	if not wait_choose_actors(targetIds, msg, true):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20627_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var msg = "佯作纵火，诱发{0}乱动\n可否？".format([
		ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20627_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	var se = DataManager.get_current_stratagem_execution()
	se.set_target(targetId)
	ske.play_se_animation(se, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_result")
	return

func effect_20627_result() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var positions = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = targetWA.position + dir
		if targetWA.try_move(pos):
			positions.append(pos)
	if positions.empty():
		skill_end_clear()
		return
	positions.shuffle()

	ske.cost_war_cd(1)
	ske.change_war_actor_position(targetId, positions[0])
	ske.war_report()

	play_dialog(targetId, "敌军纵火\n速速回避！", 0, 2999)
	return

func _get_available_targets() -> PoolIntArray:
	var se = DataManager.new_stratagem_execution(actorId, "火计")
	var ret = se.get_available_targets()
	var targetIds = ret[0]
	for targetId in ret[1]:
		targetIds.erase(targetId)
	var canMoveTargetIds = []
	for targetId in targetIds:
		var wa = DataManager.get_war_actor(targetId)
		for dir in StaticManager.NEARBY_DIRECTIONS:
			var pos = wa.position + dir
			if wa.try_move(pos):
				canMoveTargetIds.append(targetId)
				break
	return canMoveTargetIds
