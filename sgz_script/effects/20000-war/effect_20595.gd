extends "effect_20000.gd"

# 断归限定技
#【断归】大战场，限定技。你非主将，可选择一名身侧敌方武将，隐藏埋伏下来。下个回合，如果该武将移动，立刻占据该武将移动前的位置。若该武将未移动，你在其回合结束时显形。

const EFFECT_ID = 20595
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20595_start() -> void:
	var targetIds = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = me.position + dir
		var wa = DataManager.get_war_actor_by_position(pos)
		if not me.is_enemy(wa):
			continue
		targetIds.append(wa.actorId)
	if targetIds.empty():
		var msg = "没有可以发动【{0}】的目标".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return
	if targetIds.size() == 1:
		DataManager.set_env("目标", targetIds[0])
		goto_step("selected")
		return
	var msg = "选择【{0}】目标".format([ske.skill_name])
	if not wait_choose_actors(targetIds, msg):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20595_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var msg = "原地潜伏，等待{0}异动\n可否？".format([
		ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(actorId, msg, 2, 2001, true)
	map.next_shrink_actors = [actorId, targetId]
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20595_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	var flags = [targetId, targetWA.position.x, targetWA.position.y]
	ske.set_war_skill_val(flags)
	ske.cost_war_cd(99999)

	var msg = "全军静默，待时而动"
	play_dialog(actorId, msg, 2, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_yesno(FLOW_BASE + "_hide")
	return

func effect_20595_hide() -> void:
	me.ambush(me.position)
	map.draw_actors()
	skill_end_clear()
	FlowManager.add_flow("player_skill_end_trigger")
	return
