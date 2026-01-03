extends "effect_20000.gd"

# 闪影限定技
#【闪影】大战场，限定技。指定一个对方武将，以其为对称中心，你移动到以该中心对称的空位。


const EFFECT_ID = 20704
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20704_start() -> void:
	var targetIds = []
	for targetId in get_enemy_targets(me):
		var wa = DataManager.get_war_actor(targetId)
		var pos = wa.position * 2 - me.position
		if not map.is_valid_position(pos):
			continue
		var terrian = map.get_blockCN_by_position(pos)
		if terrian in StaticManager.CITY_BLOCKS_CN:
			continue
		var existing = DataManager.get_war_actor_by_position(pos)
		if existing != null:
			continue
		targetIds.append(targetId)

	if targetIds.empty():
		var msg = "没有可发动【{0}】的目标".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return
	
	if not wait_choose_actors(targetIds, "选择对手发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20704_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var pos = targetWA.position * 2 - me.position
	var msg = "对{0}发动【{1}】\n移动到其侧后\n可否？".format([
		targetWA.get_name(), ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	map.show_color_block_by_position([pos])
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20704_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var pos = targetWA.position * 2 - me.position
	map.show_color_block_by_position([])
	ske.cost_war_cd(99999)
	ske.change_war_actor_position(actorId, pos)
	ske.war_report()
	map.draw_actors()
	var msg = "踏破虚空，千仞一线！"
	play_dialog(actorId, msg, 0, 2999)
	return
