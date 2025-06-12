extends "effect_20000.gd"

#引计主动技
#【引计】大战场,主动技。你可以指定一个对方非城地形的武将，该武将立即进入移动状态，你可以消耗5点机动力，该对方武将移动一格。每回合限一次

const EFFECT_ID = 20132
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 5

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_choose_position(FLOW_BASE + "_3")
	return

func on_view_model_2002():
	wait_for_yesno(FLOW_BASE + "_4")
	return

func on_view_model_2003():
	wait_for_skill_result_confirmation()
	return

func effect_20132_start():
	map.show_color_block_by_position([])
	if not assert_action_point(me.actorId, COST_AP):
		return
	var msg = "选择敌军发动【{0}】".format([ske.skill_name])
	if not wait_choose_actors(get_enemy_targets(me), msg):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20132_2():
	var targetId = get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	var targets = [];#移动目标列表
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = targetWA.position + dir
		if pos.x < 0 or pos.x >= map.cell_columns:
			continue
		if pos.y < 0 or pos.y >= map.cell_rows - 1:
			continue
		var blockCN = map.get_blockCN_by_position(pos)
		if blockCN in StaticManager.CITY_BLOCKS_CN:
			# 不能选城地形
			continue
		if not targetWA.can_move_to_position(pos):
			continue
		targets.append(pos);
	if targets.empty():
		var msg = "敌军无法移动"
		play_dialog(-1, msg, 2, 2003)
		return

	map.set_cursor_location(targets[0], true)
	map.show_color_block_by_position(targets);
	SceneManager.show_unconfirm_dialog("请指定位移地点")
	set_env("可选目标", targets)
	DataManager.set_target_position(targets[0])
	LoadControl.set_view_model(2001)
	return

func effect_20132_3():
	var msg = "使用{0}机动力\n发动【{1}】，可否".format([
		COST_AP, ske.skill_name
	])
	play_dialog(me.actorId, msg, 2, 2002, true)
	return

func effect_20132_4():
	var targetId = get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var targetPosition = DataManager.get_target_position()

	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	ske.change_war_actor_position(targetId, targetPosition)
	ske.war_report()
	map.show_color_block_by_position([])
	var msg = "{0}已入彀\n计将安出？".format([targetActor.get_name()])
	FlowManager.add_flow("draw_actors")
	play_dialog(me.actorId, msg, 1, 2003)
	return
