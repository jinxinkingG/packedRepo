extends "effect_20000.gd"

# 烈袭主动技
#【烈袭】大战场，主动技。以你为中心，十字线上、6格以内可无障碍触及的对方武将，若其武力低于你，你可消耗3机动力发动，移动 X 格至与其相邻位置，你立即与之进入白刃战，并在本场战争中临时获得<画戟>。技能冷却Y回合。Y默认为5，若白刃战胜利，Y=5-X。

const EFFECT_ID = 20654
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 3
const BASIC_CD = 5

func on_trigger_20020() -> bool:
	var bf = DataManager.get_current_battle_fight()
	if bf.source != ske.skill_name:
		return false
	var cd = BASIC_CD
	var x = ske.get_war_skill_val_int()
	var winner = bf.get_winner()
	if winner != null and winner.actorId == actorId:
		cd = cd - x
	if cd > 0:
		ske.cost_war_cd(cd)
		ske.war_report()
	return false

func check_AI_perform_20000()->bool:
	# AI 暂不发动
	return false

func effect_20654_start() -> void:
	if not assert_action_point(actorId, COST_AP):
		return
	var probed = _get_available_perform_targets(me)
	var targetIds = probed[0]
	# 判断是否可发动，区分显示和提示
	var disabled = []
	var available = []
	for targetId in targetIds:
		var wa = DataManager.get_war_actor(targetId)
		if wa == null:
			continue
		if wa.get_power() >= me.get_power():
			disabled.append(wa.actorId)
		else:
			available.append(wa.actorId)
	if targetIds.size() <= disabled.size():
		var msg = "没有可以发动【{0}】的目标"
		if not disabled.empty():
			msg += "\n（目标不满足武力条件"
		msg = msg.format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		map.show_color_block_by_position(probed[1])
		return

	if targetIds.size() == 1 and available.size() == 1:
		var wa = DataManager.get_war_actor(available[0])
		map.set_cursor_location(wa.position, true)
		DataManager.set_env("目标", wa.actorId)
		goto_step("selected")
		return

	var msg = "选择【{0}】目标".format([ske.skill_name])

	if not wait_choose_actors(targetIds, msg):
		return
	map.show_can_choose_actors(targetIds, -1, disabled)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20654_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	if targetWA.get_power() >= me.get_power():
		var msg = "{0}勇力更胜\n未可发动【{1}】".format([
			targetWA.get_name(), ske.skill_name,
		])
		play_dialog(actorId, msg, 3, 2002)
		return
	var msg = "消耗{0}机动力\n移动到{1}附近并发起攻击\n可否？".format([
		COST_AP, targetWA.get_name(),
	])
	play_dialog(actorId, msg, 2, 2001, true)
	map.show_can_choose_actors([targetId])
	var dir = targetWA.position.direction_to(me.position)
	map.show_color_block_by_position([targetWA.position + dir])
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20654_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var dir = targetWA.position.direction_to(me.position)
	var pos = targetWA.position + dir
	var x = Global.get_distance(pos, me.position)
	ske.set_war_skill_val(x, 1)
	ske.cost_ap(COST_AP, true)
	ske.change_war_actor_position(actorId, pos)
	ske.add_war_skill(actorId, "画戟", 99999)
	ske.war_report()
	map.show_color_block_by_position([])
	var msg = "烈如火，疾如风！"
	if actorId == StaticManager.ACTOR_ID_LVLINGQI:
		msg = "以吾父之名\n" + msg
	me.attach_free_dialog(msg, 0)
	start_battle_and_finish(actorId, targetId)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_start")
	return

# 检查发动目标，返回可发动的目标和阻挡位置（用于提示）
# @return [targets, blockingPositions]
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
				#if me.is_enemy(wa) and wa.actor().get_power() < actor.get_power() and x > 1:
				# 不再预先判断武力，而是在发动时区分提示
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
