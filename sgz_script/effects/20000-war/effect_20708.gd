extends "effect_20000.gd"

# 横锁主动技
#【横锁】大战场，主动技。你为守方时才能使用：你可消耗6点机动力，指定1格水地形，标记或撤销 {横锁} 地形。每回合限1次。


const EFFECT_ID = 20708
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 6

func effect_20708_start() -> void:
	if not assert_action_point(actorId, COST_AP):
		return
	map.aStar.update_map_for_actor(me)
	var targetPositions = []
	var nearest = null
	for x in range(-6, 6):
		for y in range(-6, 6):
			var pos = me.position + Vector2(x, y)
			if not map.is_valid_position(pos):
				continue
			var terrian = map.get_blockCN_by_position(pos)
			if not terrian in ["河流"]:
				continue
			var wa = DataManager.get_war_actor_by_position(pos)
			if wa != null:
				continue
			if map.aStar.get_skill_path(me.position, pos, 6).size() <= 1:
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
	SceneManager.show_unconfirm_dialog("于何处「横锁」？", actorId)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_position(FLOW_BASE + "_selected")
	return

func effect_20708_selected() -> void:
	var pos = DataManager.get_target_position()
	var action = "标记"
	if map.is_water_locked(pos):
		action = "撤销"
	var msg = "消耗{0}机动力\n于此处{1}【{2}】\n可否？".format([
		COST_AP, action, ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	map.show_color_block_by_position([pos])
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20708_confirmed() -> void:
	var pos = DataManager.get_target_position()

	ske.cost_ap(COST_AP)
	map.switch_water_lock(actorId, pos)
	ske.cost_war_cd(1)
	ske.war_report()

	var msg = "横江锁流，此路不通！"
	if not map.is_water_locked(pos):
		msg = "拔除锁链，乘流飞渡！"
	play_dialog(actorId, msg, 0, 2999)
	return
