extends "effect_20000.gd"

#散谣主动技
#【散谣】大战场，主动技。你消耗8点机动力，指定一个对方武将非城地形，使其随机移动2步。每日限一次。

const EFFECT_ID = 20553
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 8

# 发动主动技
func effect_20553_start() -> void:
	if not assert_action_point(actorId, COST_AP):
		return
	var targets = get_enemy_targets(me)
	if targets.empty():
		var msg = "没有合适的发动对象"
		play_dialog(actorId, msg, 2, 2999)
		return
	var msg = "选择敌军发动【{0}】"
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

# 已选定队友
func effect_20553_2() -> void:
	var targetId = DataManager.get_env_int("目标")

	var msg = "人心难测\n流言起时，{0}能自安否？".format([
		DataManager.get_actor_honored_title(targetId, actorId)
	])
	play_dialog(actorId, msg, 1, 2001)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20553_3() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var original = targetWA.position

	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)

	var dirs = StaticManager.NEARBY_DIRECTIONS.duplicate()
	for i in 2:
		dirs.shuffle()
		for dir in dirs:
			var pos = dir + targetWA.position
			if pos == original:
				continue
			if targetWA.try_move(pos):
				ske.change_war_actor_position(targetId, pos)
				map.draw_actors()
				break

	ske.war_report()

	var msg = "贼子可恨！\n约束全军，定心备战！"
	play_dialog(targetId, msg, 0, 2999)
	return
