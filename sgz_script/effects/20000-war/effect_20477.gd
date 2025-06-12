extends "effect_20000.gd"

#跃马主动技部分
#【跃马】大战场，主动技。消耗5点机动力，选择一个非城地形的马走日目标位置跳进。目标位置如果有敌军，对其发起战斗；目标位置如果是空地，或战斗结束后成为空地，则移动到目标位置。每回合限1次。

const EFFECT_ID = 20477
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 5

func effect_20477_start()->void:
	if not assert_action_point(actorId, COST_AP):
		return
	var candidates = []
	for x in [-1, 1]:
		for y in [-2, 2]:
			candidates.append(me.position + Vector2(x, y))
			candidates.append(me.position + Vector2(y, x))
	var positions = []
	for pos in candidates:
		if not map.is_valid_position(pos):
			continue
		var wa = DataManager.get_war_actor_by_position(pos)
		if wa != null and not wa.is_enemy(me):
			continue
		var terrian = map.get_blockCN_by_position(pos)
		if terrian in StaticManager.CITY_BLOCKS_CN:
			continue
		var checkings = []
		if abs(me.position.x - pos.x) == 1:
			# 纵跳
			var midY = int((pos.y + me.position.y) / 2)
			checkings.append(Vector2(pos.x, midY))
			checkings.append(Vector2(me.position.x, midY))
		else:
			# 横跳
			var midX = int((pos.x + me.position.x) / 2)
			checkings.append(Vector2(midX, pos.y))
			checkings.append(Vector2(midX, me.position.y))
		var valid = false
		for p in checkings:
			var midTerrian = map.get_blockCN_by_position(p)
			if me.can_move_to_position(p) and not midTerrian == "城墙":
				valid = true
				break
		if not valid:
			continue
		positions.append(pos)
	if positions.empty():
		play_dialog(actorId, "没有可以跃马的位置", 3, 2999)
		return
	map.clear_can_choose_actors()
	map.show_color_block_by_position(positions)
	DataManager.set_env("可选目标", positions)
	DataManager.set_target_position(positions[0])
	SceneManager.show_unconfirm_dialog("跃马何处？", actorId)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_choose_position(FLOW_BASE + "_2")
	return

func effect_20477_2()->void:
	var pos = DataManager.get_target_position()
	var wa = DataManager.get_war_actor_by_position(pos)
	var msg = "消耗{0}机动力\n移动到目标位置\n可否？".format([
			COST_AP,
		])
	var actors = [actorId]
	if wa != null and not wa.disabled:
		msg = "消耗{0}机动力\n跳攻{1}\n可否？".format([
			COST_AP, wa.get_name(),
		])
		actors = [wa.actorId, actorId]
	play_dialog(actorId, msg, 2, 2001, true)
	map.next_shrink_actors = actors
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20477_3()->void:
	var pos = DataManager.get_target_position()
	var wa = DataManager.get_war_actor_by_position(pos)

	ske.cost_ap(5, true)
	ske.cost_war_cd(1)

	map.show_color_block_by_position([])
	if wa == null or wa.disabled:
		# 没人，跳过去
		ske.change_war_actor_position(actorId, pos)
		ske.war_report()
		var msg = "骐骥一跃\n岂鞍鞯可羁！"
		play_dialog(actorId, msg, 2, 2999)
		return
	# 有人，跳攻
	var msg = "骐骥一跃\n{0}可接得住？".format([
		DataManager.get_actor_naughty_title(wa.actorId, actorId),
	])
	play_dialog(actorId, msg, 0, 2002)
	return

func on_view_model_2002()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_20477_4()->void:
	var pos = DataManager.get_target_position()
	var wa = DataManager.get_war_actor_by_position(pos)
	var val = [wa.actorId, pos.x, pos.y]
	ske.set_war_skill_val(val, 1)
	map.next_shrink_actors = []
	start_battle_and_finish(actorId, wa.actorId)
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation()
	return
