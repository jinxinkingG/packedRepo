extends "effect_20000.gd"

#跬步锁定技
#【跬步】大战场，主将主动技。选择一个“与你相邻的己方武将周围的空位”，你移动到该位置，每回合限1次

const EFFECT_ID = 20547
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20547_start() -> void:
	var targets = []
	for targetId in get_teammate_targets(me):
		var wa = DataManager.get_war_actor(targetId)
		for dir in StaticManager.NEARBY_DIRECTIONS:
			var pos = wa.position + dir
			if me.can_move_to_position(pos):
				targets.append(pos)
	if targets.empty():
		var msg = "没有可移动的位置"
		play_dialog(actorId, msg, 3, 2999)
		return

	map.set_cursor_location(targets[0], true)
	map.show_color_block_by_position(targets)
	var msg = "选择【{0}】目标位置".format([ske.skill_name])
	SceneManager.show_unconfirm_dialog(msg)
	DataManager.set_env("可选目标", targets)
	DataManager.set_target_position(targets[0])
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_position(FLOW_BASE + "_move")
	return

func effect_20547_move() -> void:
	var pos = DataManager.get_target_position()
	ske.cost_war_cd(1)
	ske.change_war_actor_position(actorId, pos)
	ske.war_report()
	map.draw_actors()
	var msg = "卑膝苟存 ……"
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var wa = DataManager.get_war_actor_by_position(pos + dir)
		if me.is_teammate(wa):
			msg = "{0}，尚赖庇佑".format([
				DataManager.get_actor_honored_title(wa.actorId, actorId)
			])
			break
	play_dialog(actorId, msg, 3, 2999)
	return
