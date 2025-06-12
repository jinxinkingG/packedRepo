extends "effect_20000.gd"

# 墨拥主动技
#【墨拥】大战场，主动技。指定你身边一个非城地形的空地，消耗5点机动力：令张飞尝试移动到该处。每回合限1次；若移动成功，冷却5回合。

const EFFECT_ID = 20570
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 5
const TARGET_ID = StaticManager.ACTOR_ID_ZHANGFEI

func effect_20570_start() -> void:
	if not assert_action_point(me.actorId, COST_AP):
		return

	var positions = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = me.position + dir
		if not me.can_move_to_position(pos):
			continue
		var terrian = map.get_blockCN_by_position(pos)
		if terrian in StaticManager.CITY_BLOCKS_CN:
			continue
		positions.append(pos)

	if positions.empty():
		var msg = "没有可以发动的空位"
		play_dialog(actorId, msg, 3, 2999)
		return

	if positions.size() == 1:
		DataManager.set_target_position(positions[0])
		goto_step("selected")
		return

	map.set_cursor_location(positions[0], true)
	map.show_color_block_by_position(positions)
	SceneManager.show_unconfirm_dialog("请指定发动地点")
	DataManager.set_env("可选目标", positions)
	DataManager.set_target_position(positions[0])
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_position(FLOW_BASE + "_selected")
	return

func effect_20570_selected() -> void:
	var pos = DataManager.get_target_position()
	map.show_color_block_by_position([pos])

	var msg = "尝试令张飞移动到此处\n可否？"
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20570_confirmed() -> void:
	var pos = DataManager.get_target_position()
	map.show_color_block_by_position([])
	map.cursor.hide()

	ske.cost_ap(COST_AP, true)
	ske.cost_war_cd(1)

	var him = DataManager.get_war_actor(TARGET_ID)
	if him == null or him.disabled or not him.has_position():
		var msg = "… …\n思君不见，归期何期"
		play_dialog(actorId, msg, 3, 2999)
		return

	if him.vstateId != me.vstateId:
		var msg = "… …\n墨香犹在，人已两宽"
		play_dialog(actorId, msg, 2, 2002)
		return

	ske.change_war_actor_position(him.actorId, pos)
	ske.cost_war_cd(5)
	ske.war_report()

	var msg = "{0}在此！\n何人敢对{1}无礼？".format([
		DataManager.get_actor_self_title(him.actorId),
		DataManager.get_actor_honored_title(actorId, him.actorId),
	])
	play_dialog(him.actorId, msg, 0, 2999)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_respond")
	return

func effect_20570_respond() -> void:
	var him = DataManager.get_war_actor(TARGET_ID)
	var msg = "… …"
	play_dialog(him.actorId, msg, 2, 2999)
	return
