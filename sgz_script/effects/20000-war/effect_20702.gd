extends "effect_20000.gd"

# 斩道主动技
#【斩道】大战场，主动技。指定1个6格内的非城地形，消耗5点机动力发动，标记目标位置。若敌将移至被你标记过位置时，令其选择一项：1.你与其进入白刃战；2.结算一次火计伤害。战争中至多存在5个标记位置，每回合限1次。


const EFFECT_ID = 20702
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const BUFF_NAME = "斩道"
const COST_AP = 5
const MAX_MARK_COUNT = 5

func effect_20702_start() -> void:
	if not assert_action_point(actorId, COST_AP):
		return
	map.aStar.update_map_for_actor(me)
	var targetPositions = []
	var markedPositions = get_marked_positions()
	var nearest = null
	for x in range(-6, 6):
		for y in range(-6, 6):
			var pos = me.position + Vector2(x, y)
			if pos in markedPositions:
				continue
			if not map.is_valid_position(pos):
				continue
			if map.aStar.get_skill_path(me.position, pos, 6).size() <= 1:
				continue
			var terrian = map.get_blockCN_by_position(pos)
			if terrian in StaticManager.CITY_BLOCKS_CN:
				continue
			var wa = DataManager.get_war_actor_by_position(pos)
			if wa != null:
				continue
			targetPositions.append(pos)
			if nearest == null:
				nearest = pos
			elif Global.get_distance(pos, me.position) < Global.get_distance(nearest, me.position):
				nearest = pos
	if targetPositions.empty():
		play_dialog(actorId, "没有可以发动的空位", 3, 2999)
		return
	map.clear_can_choose_actors()
	map.show_color_block_by_position(targetPositions)
	DataManager.set_env("可选目标", targetPositions)
	DataManager.set_target_position(nearest)
	SceneManager.show_unconfirm_dialog("斩道何处？", actorId)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_position(FLOW_BASE + "_selected")
	return

func effect_20702_selected() -> void:
	var pos = DataManager.get_target_position()
	var msg = "消耗{0}机动力\n于此处【{1}】\n可否？".format([
		COST_AP, ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	map.show_color_block_by_position([pos])
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20702_confirmed() -> void:
	var pos = DataManager.get_target_position()
	mark_position(pos)
	ske.cost_ap(COST_AP)
	ske.cost_war_cd(1)
	ske.war_report()

	map.show_color_block_by_position(get_marked_positions())
	play_dialog(actorId, "此路通否，须得问过本将！", 0, 2999)
	return

func get_marked_positions() -> PoolVector2Array:
	var marked = ske.get_war_skill_val_int_array()
	var markedPositions = []
	for i in range(0, marked.size(), 2):
		var x = marked[i]
		var y = marked[i + 1]
		markedPositions.append(Vector2(x, y))
	return markedPositions

func mark_position(pos: Vector2) -> void:
	var marked = ske.get_war_skill_val_int_array()
	marked.insert(0, pos.y)
	marked.insert(0, pos.x)
	if marked.size() > MAX_MARK_COUNT * 2:
		marked = marked.slice(0, MAX_MARK_COUNT * 2 - 1)
	ske.set_war_skill_val(marked)
	# 整体刷新 area buff
	var i = 0
	for p in get_marked_positions():
		var key = ske.skill_name + "_" + str(i)
		me.set_areas(key, BUFF_NAME, actorId, 99, p)
		i += 1
	return
