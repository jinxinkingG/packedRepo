extends "effect_20000.gd"

#避凶诱发技
#【避凶】大战场，主将诱发技。你方武将受到伤兵类计策伤害时，你可令该武将移动一格。（无需消耗机动力）

const EFFECT_ID = 20536
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20012()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	if se.get_soldier_damage_for(se.targetId) <= 0:
		return false
	var wa = me
	if se.targetId != actorId:
		wa = DataManager.get_war_actor(se.targetId)
		if not me.is_teammate(wa):
			return false
	var targets = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = wa.position + dir
		if not wa.try_move(pos):
			continue
		targets.append(pos)
	if targets.empty():
		return false

	if me.get_controlNo() < 0 and se.name == "伪击转杀":
		# 特殊情况，AI 不发动
		return false
	return true

func effect_20536_AI_start():
	goto_step("start")
	return

func effect_20536_start():
	var se = DataManager.get_current_stratagem_execution()
	var wa = DataManager.get_war_actor(se.targetId)

	var targets = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = wa.position + dir
		if not wa.try_move(pos):
			continue
		targets.append(pos)

	if me.get_controlNo() < 0:
		var enemy = DataManager.get_war_actor(se.fromId)
		# 尽可能远离计策目标
		var maxDistance = -1
		for pos in targets:
			var distance = Global.get_distance(pos, enemy.position)
			if distance > maxDistance:
				maxDistance = distance
				DataManager.set_target_position(pos)
		goto_step("2")
		return

	map.set_cursor_location(targets[0], true)
	map.show_color_block_by_position(targets)
	SceneManager.show_unconfirm_dialog("请指定位移地点")
	DataManager.set_env("可选目标", targets)
	DataManager.set_target_position(targets[0])
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_position(FLOW_BASE + "_2")
	return

func effect_20536_2():
	var se = DataManager.get_current_stratagem_execution()
	var targetPosition = DataManager.get_target_position()

	ske.change_war_actor_position(se.targetId, targetPosition)
	ske.war_report()
	map.show_color_block_by_position([])

	var msg = "此地大凶\n{0}当趋避之".format([
		DataManager.get_actor_honored_title(se.targetId, actorId),
	])
	play_dialog(actorId, msg, 2, 2001)
	map.next_shrink_actors = [actorId, se.targetId]
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation("")
	return
