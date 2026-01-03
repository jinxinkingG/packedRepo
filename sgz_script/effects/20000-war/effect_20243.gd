extends "effect_20000.gd"

# 神速主动技实现
#【神速】大战场,主动技。你可以指定一个，以你为中心，十字6格内可无障碍触及的对方武将，对该武将发起攻击宣言，每日限1次。

const EFFECT_ID = 20243
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20243_start():
	var probed = _get_available_perform_targets(me)
	var targetIds = probed[0]
	if targetIds.empty():
		var msg = "没有可以发动【{0}】的目标"
		if not probed[1].empty():
			msg += "\n（部分目标被地形阻隔"
		msg = msg.format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		map.show_color_block_by_position(probed[1])
		return
	if not wait_choose_actors(targetIds, "选择敌军发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20243_2():
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var msg = "发动{0}，奇袭{1}\n可否？".format([
		ske.skill_name, targetWA.get_name(),
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20243_3():
	var msg = "吾亦可……所向无前！"
	if actorId == StaticManager.ACTOR_ID_XIAHOUYUAN:
		msg = "虎步天下，所向无前！"
	elif actorId == StaticManager.ACTOR_ID_WUYI:
		msg = "车骑高劲，所向无前！"
	elif actorId == StaticManager.ACTOR_ID_CAOCHUN:
		msg = "千里趋敌，所向无前！"
	play_dialog(actorId, msg, 0, 2002)
	return

func on_view_model_2002()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_20243_4():
	var targetId = DataManager.get_env_int("目标")
	ske.cost_war_cd(1)
	start_battle_and_finish(actorId, targetId)
	return

# 检查发动目标，返回可发动的目标和阻挡位置（用于提示）
# @return [[targetIds], [blockingPositions]]
func _get_available_perform_targets(me:War_Actor) -> Array:
	var targetIds = []
	var blockingPositions = []
	var distance = get_choose_distance()
	for dir in StaticManager.NEARBY_DIRECTIONS:
		for x in range(1, distance + 1):
			var pos = me.position + dir * x
			if not map.is_valid_position(pos):
				break
			var wa = DataManager.get_war_actor_by_position(pos)
			if wa != null:
				if me.is_enemy(wa) and x > 1:
					targetIds.append(wa.actorId)
				# 发现部队，无论是否目标，都形成隔断
				break
			# 城地形隔断
			var terrian = map.get_blockCN_by_position(pos)
			if terrian in StaticManager.CITY_BLOCKS_CN:
				blockingPositions.append(pos)
				break
	targetIds = check_combat_targets(targetIds)
	return [targetIds, blockingPositions]
