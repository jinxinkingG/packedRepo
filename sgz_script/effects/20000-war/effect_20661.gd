extends "effect_20000.gd"

# 急回主动技
#【急回】大战场，主动技。若你为守方，你可消耗所有机动力（至少1点）发动。回到距离你最近的1个无人占领的城门上。每回合限1次。

const EFFECT_ID = 20661
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 5
const BUFF_NAME = "探明"

func check_AI_perform_20000()->bool:
	# AI 暂不发动
	return false

func effect_20661_start() -> void:
	var minDistance = 999
	var targetPosition = Vector2(-1, -1)
	for pos in map.door_position:
		var wa = DataManager.get_war_actor_by_position(pos)
		if wa != null and not wa.disabled:
			continue
		var distance = Global.get_distance(pos, me.position)
		if distance < minDistance:
			minDistance = distance
			targetPosition = pos
	if not map.is_valid_position(targetPosition):
		var msg = "没有空城门可以【{0}】".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return

	var msg = "消耗{0}机动力\n回到最近的城门\n可否？".format([
		me.action_point,
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000()->void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20661_confirmed() -> void:
	var minDistance = 999
	var targetPosition = Vector2(-1, -1)
	for pos in map.door_position:
		var wa = DataManager.get_war_actor_by_position(pos)
		if wa != null and not wa.disabled:
			continue
		var distance = Global.get_distance(pos, me.position)
		if distance < minDistance:
			minDistance = distance
			targetPosition = pos
	if not map.is_valid_position(targetPosition):
		var msg = "没有空城门可以【{0}】".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return

	ske.cost_ap(me.action_point, true)
	ske.cost_war_cd(1)
	ske.change_war_actor_position(actorId, targetPosition)
	ske.war_report()
	var msg = "万不可被{0}抄了后路！".format([
		me.get_war_enemy_leader().get_name(),
	])
	play_dialog(actorId, msg, 2, 2999)
	return
