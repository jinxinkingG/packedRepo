extends "effect_20000.gd"

# 奔袭主动技实现
#【奔袭】大战场，主动技。你可以指定一个对方武将，消耗（2+2x）点机动力，你与该武将进入白刃战。x＝你和该武将的横纵距离的较大值。

const EFFECT_ID = 20269
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const EXTRA_AP = 2

func effect_20269_start() -> void:
	var targets = []
	for targetId in get_combat_targets(me):
		var targetWA = DataManager.get_war_actor(targetId)
		var distance = Global.get_range_distance(me.position, targetWA.position)
		if distance <= 1:
			continue
		var apCost = _get_ap_cost(targetId)
		if me.action_point < apCost:
			# 机动力不足均跳过
			continue
		targets.append(targetId)
	if targets.empty():
		var msg = "没有可以【{0}】的目标".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return
	var msg = update_choose_actor_message(targets[0])
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20269_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var apCost = _get_ap_cost(targetId)
	if not assert_action_point(actorId, apCost):
		return
	var msg = "消耗{0}机动力\n【{1}】{2}\n可否？".format([
		apCost, ske.skill_name, ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20269_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	var apCost = _get_ap_cost(targetId)
	ske.cost_ap(apCost, true)
	map.update_ap()
	var msg = "动如雷霆，力出万钧！\n{0}接战！".format([
		DataManager.get_actor_naughty_title(targetId, actorId),
	])
	play_dialog(actorId, msg, 0, 2002)
	map.next_shrink_actors = [actorId, targetId]
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_go")
	return

func effect_20269_go() -> void:
	var targetId = DataManager.get_env_int("目标")
	map.next_shrink_actors = []
	start_battle_and_finish(actorId, targetId)
	return

func _get_ap_cost(targetId:int)->int:
	var target = DataManager.get_war_actor(targetId)
	if target == null:
		return 999
	var distance = Global.get_range_distance(me.position, target.position)
	return 2 + EXTRA_AP * distance

func update_choose_actor_message(targetId:int)->String:
	var msg = "选择敌军发动【{0}】".format([ske.skill_name])
	if actorId < 0:
		return msg
	var apCost = _get_ap_cost(targetId)
	msg += "（需机动：{0}".format([apCost])
	return msg
