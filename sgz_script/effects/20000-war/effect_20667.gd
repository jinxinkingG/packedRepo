extends "effect_20000.gd"

# 诳武主动技 #发起攻击
#【诳武】大战场，主动技。你可消耗所有机动力（至少1），选择1名相邻敌将发动。你与之进入白刃战，若此战你获胜，恢复因发动而消耗的机动力，每回合限3次。

const EFFECT_ID = 20667
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const TIMES_LIMIT = 3
const PASSIVE_EFFECT_ID = 20668

func check_AI_perform_20000()->bool:
	# AI 暂不发动
	return false

func effect_20667_start() -> void:
	var targetIds = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var wa = DataManager.get_war_actor_by_position(me.position + dir)
		if not me.is_enemy(wa):
			continue
		targetIds.append(wa.actorId)
	targetIds = check_combat_targets(targetIds)

	if targetIds.empty():
		var msg = "没有可以发动【{0}】的目标".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return

	if targetIds.size() == 1:
		DataManager.set_env("目标", targetIds[0])
		goto_step("selected")
		return

	var msg = "选择【{0}】目标".format([ske.skill_name])
	wait_choose_actors(targetIds, msg, true)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20667_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	var msg = "消耗全部（{0}）机动力\n【{1}】攻击{2}\n可否？".format([
		me.action_point, ske.skill_name, targetWA.get_name(),
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20667_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	ske.cost_war_limited_times(TIMES_LIMIT)
	var ap = ske.cost_ap(me.action_point, true)
	# 记录消耗的机动力
	ske.set_war_skill_val(ap, 1, PASSIVE_EFFECT_ID)
	ske.war_report()
	var msg = "何须留力\n雷霆一击！\n（机动力归零"
	me.attach_free_dialog(msg, 0)
	start_battle_and_finish(actorId, targetId)
	return
