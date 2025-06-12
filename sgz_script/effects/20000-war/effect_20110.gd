extends "effect_20000.gd"

#彰勇诱发技 #胜利触发 #位移
#【彰勇】大战场，诱发技。你白刃战胜利时，若对方被消灭，可以移动到对方位置；若对方未被消灭，则你选择对方相邻的一个空位（太守府除外），然后你位移到这一格。

const EFFECT_ID = 20110
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20020()->bool:
	# 托管模式下不发动
	if me.war_vstate().delegated:
		skill_end_clear()
		return false
	# 战后
	var bf = DataManager.get_current_battle_fight()
	var loser = bf.get_loser()
	if loser == null:
		return false
	var winner = loser.get_battle_enemy_war_actor()
	if winner == null or winner.actorId != actorId:
		# 不是胜利方
		return false
	var positions = _get_available_positions(loser.actorId)
	return positions.size() > 0

func effect_20110_start():
	var bf = DataManager.get_current_battle_fight()
	map.show_color_block_by_position([])

	var positions = _get_available_positions(bf.get_loser().actorId)
	if positions.empty():
		LoadControl.end_script()
		return
	if positions.size() == 1:
		# 只有一个位置，不必选择，直接飞
		DataManager.set_target_position(positions[0])
		goto_step("2")
		return

	map.set_cursor_location(positions[0], true)
	map.show_color_block_by_position(positions)
	SceneManager.show_unconfirm_dialog("请指定【彰勇】追击地点")
	DataManager.set_env("可选目标", positions)
	DataManager.set_target_position(positions[0])
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_choose_position(FLOW_BASE + "_2", false)
	return

func effect_20110_2():
	var bf = DataManager.get_current_battle_fight()

	var nextPosition = DataManager.get_target_position()

	# 发动彰勇
	me.position = nextPosition
	map.next_shrink_actors = [me.actorId, me.get_battle_enemy_war_actor().actorId]
	map.show_color_block_by_position([])
	FlowManager.add_flow("draw_actors")
	var msg = "奋余勇，追穷寇！"
	play_dialog(actorId, msg, 0, 2001)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001()->void:
	wait_for_skill_result_confirmation("")
	return

func _get_available_positions(targetId:int)->Array:
	var bf = DataManager.get_current_battle_fight()
	# 位置总是以战斗信息为准
	var pos = bf.get_position()
	var targetWA = DataManager.get_war_actor(targetId)
	if targetWA == null or targetWA.disabled or not targetWA.has_position():
		# 目标已经不在战场，直接飞过去
		if not _target_position_valid(pos):
			return []
		return [pos]

	# 对手仍在，取其周边位置
	var positions = []
	pos = targetWA.position
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var p = pos + dir
		if not _target_position_valid(p):
			continue
		positions.append(p)
	return positions

# 目标位置是非可飞
func _target_position_valid(pos:Vector2)->bool:
	if pos == me.position:
		return false
	if not me.can_move_to_position(pos):
		return false
	var blockCN = map.get_blockCN_by_position(pos)
	if blockCN == "太守府":
		return false
	return true
