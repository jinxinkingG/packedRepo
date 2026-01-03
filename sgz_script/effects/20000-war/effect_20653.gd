extends "effect_20000.gd"

# 决堤限定技
#【决堤】大战场，限定技。你在水地形可以发动，你选择一个方向，消耗15点机动力：①该方向5×6区域内的所有平地都临时变为水地形，持续2日。②该区域内所有单位随机受到你1~3倍乱水计策伤害，并附加1~2回合 {疲兵} 状态。③决堤可能对百姓、农田等造成损害，有伤天和，慎用：每发动一次，你的德-X，X=命中人数，你的德不足75时，无法使用本技能。

const EFFECT_ID = 20653
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 15
const MIN_MORAL = 75
const ANIM = "Strategy_Water"

func on_trigger_20011() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.skill != ske.skill_name:
		return false
	var raise = randi() % 3 * 100
	change_scheme_damage_rate(raise)
	return false

func check_AI_perform_20000()->bool:
	# AI 发动条件：德足够、机动力充足、范围内有合理目标
	if actor.get_moral() < MIN_MORAL:
		return false
	if me.action_point < COST_AP:
		return false
	var targets = _get_available_perform_targets(me)
	var positions = []
	for target in targets:
		if target[1].empty() or target[2].empty():
			continue
		var diff = 0
		for wa in target[2]:
			if me.is_enemy(wa):
				diff += 1
			else:
				diff -= 1
		if diff > 1:
			return true
	return false

func effect_20653_AI_start() -> void:
	var targets = _get_available_perform_targets(me)
	var selected = []
	var score = -1
	for target in targets:
		if target[1].empty() or target[2].empty():
			continue
		var diff = 0
		for wa in target[2]:
			if me.is_enemy(wa):
				diff += 1
			else:
				diff -= 1
		if diff > score:
			selected = target
			score = diff

	if selected.empty():
		skill_end_clear()
		return
	DataManager.set_target_position(selected[0])
	map.set_cursor_location(selected[0], true)
	map.show_color_block_by_position(selected[1])
	
	var msg = "发动【{1}】".format([me.get_name(), ske.skill_name])
	play_dialog(actorId, msg, 0, 3000)
	return

func on_view_model_3000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_AI_perform")
	return

func effect_20653_AI_perform() -> void:
	_perform_skill(true, 3001)
	return

func on_view_model_3001():
	wait_for_pending_message(FLOW_BASE + "_AI_report", "AI_skill_end_trigger")
	return

func effect_20653_AI_report() -> void:
	report_skill_result_message(ske, 3001)
	return

func effect_20653_start() -> void:
	if actor.get_moral() < MIN_MORAL:
		var msg = "洪水无情，有伤天和\n当慎之（[德]不足"
		play_dialog(me.actorId, msg, 3, 2999)
		return
	if not assert_action_point(actorId, COST_AP):
		return
	var targets = _get_available_perform_targets(me)
	if targets.empty():
		var msg = "没有合适的【{0}】发动点".format([ske.skill_name])
		play_dialog(me.actorId, msg, 3, 2999)
		return
	var msg = "选择【{0}】发动点".format([ske.skill_name])

	var positions = []
	var prefered = targets[0]
	var maxScore = 0
	for target in targets:
		positions.append(target[0])
		var score = 0
		for wa in target[2]:
			if me.is_enemy(wa):
				score += 1
			else:
				score -= 1
			if score > maxScore:
				maxScore = score
				prefered = target
	map.set_cursor_location(prefered[0], true)
	SceneManager.show_unconfirm_dialog(msg)
	DataManager.set_env("可选目标", positions)
	DataManager.set_target_position(prefered[0])
	map.show_color_block_by_position(prefered[1])
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_position(FLOW_BASE + "_selected")
	var targets = _get_available_perform_targets(me)
	var pos = DataManager.get_target_position()
	var covered = []
	for target in targets:
		if target[0] == pos:
			covered = target[1]
	map.set_cursor_location(pos, true)
	map.show_color_block_by_position(covered)
	return

func effect_20653_selected() -> void:
	var targets = _get_available_perform_targets(me)
	var pos = DataManager.get_target_position()
	var covered = []
	var affected = []
	for target in targets:
		if target[0] == pos:
			covered = target[1]
			affected = target[2]

	map.show_color_block_by_position(covered)
	map.show_can_choose_actors(affected)
	var msg = "消耗{0}机动力发动【{1}】".format([
		COST_AP, ske.skill_name
	])
	if affected.size() > 0:
		msg += "\n{0}等{1}部将卷入洪水".format([
			affected[0].get_name(), affected.size()
		])
	msg += "\n可否？"
	# 不适用 play_dialog，尽可能维持计策范围显示
	SceneManager.show_yn_dialog(msg, actorId)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_decided")
	return

func effect_20653_decided() -> void:
	map.clear_can_choose_actors()
	map.next_shrink_actors = []
	_perform_skill(false, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_done")
	return

func effect_20653_done() -> void:
	var se = DataManager.get_current_stratagem_execution()
	var total = 0
	var lost = 0
	for targetId in se.get_all_damaged_targets():
		var damaged = se.get_soldier_damage_for(targetId)
		var wa = DataManager.get_war_actor(targetId)
		if me.is_enemy(wa):
			total += damaged
		else:
			lost += damaged
		var msg = "损兵<r{0}>".format([damaged])
		ske.append_message(msg, wa.actorId)
	# 计策不记日志
	se.status = 2
	var msgs = []
	var mood = 2
	if total > 0:
		msgs.append("敌军损兵{0}".format([total]))
		mood = 1
	if lost > 0:
		msgs.append("我军损兵{0}".format([lost]))
		mood = 3
	if msgs.empty():
		goto_step("report")
		return
	msgs.append("（{0}德降为{1}".format([
		actor.get_name(), actor.get_moral(),
	]))
	report_skill_result_message(ske, 2003, "\n".join(msgs), mood, actorId, false)
	return

func on_view_model_2003() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20653_report() -> void:
	report_skill_result_message(ske, 2003)
	return

# 合适的技能发动点（方向）、覆盖范围、范围内部队
# @return [pos, [coveredPositions], [affectedTargets]]
func _get_available_perform_targets(me:War_Actor)->PoolVector2Array:
	var ret = []
	# 覆盖范围 5*6
	# 方向、左上、右下
	var settings = [
		[Vector2.LEFT, me.position + Vector2(-6, -2), me.position + Vector2(-1, 2)],
		[Vector2.RIGHT, me.position + Vector2(1, -2), me.position + Vector2(6, 2)],
		[Vector2.UP, me.position + Vector2(-2, -6), me.position + Vector2(2, -1)],
		[Vector2.DOWN, me.position + Vector2(-2, 1), me.position + Vector2(2, 6)],
	]
	for setting in settings:
		var dir = setting[0]
		var pos = me.position + dir
		var affected = []
		var leftTop = setting[1]
		var rightDown = setting[2]
		var covered = map.aStar.get_flood_range(me.position, leftTop, rightDown)
		if covered.empty():
			continue
		for p in covered:
			var wa = DataManager.get_war_actor_by_position(p)
			if wa == null or wa.disabled:
				continue
			affected.append(wa)
		ret.append([pos, covered, affected])
	return ret

func _perform_skill(isAI:bool, nextViewModel:int=-1)->void:
	map.aStar.update_map_for_actor(me)
	var targets = _get_available_perform_targets(me)
	var pos = DataManager.get_target_position()
	var covered = []
	var affected = []
	for target in targets:
		if target[0] == pos:
			covered = target[1]
			affected = target[2]

	map.show_color_block_by_position(covered)
	map.show_can_choose_actors(affected)

	var dir = pos - me.position
	for p in covered:
		var terrian = map.get_blockCN_by_position(p)
		if not terrian in ["平原", "河流"]:
			continue
		map.set_temp_block(p, "river_94", 2)
	# 河流地形的具体变化，要把外面一圈也考虑进去
	var changed = covered.duplicate()
	match dir:
		Vector2.UP:
			for x in range(-2, 3):
				changed.append(me.position + Vector2(x, 0))
				changed.append(me.position + Vector2(x, -7))
			for y in range(-7, 1):
				changed.append(me.position + Vector2(-3, y))
				changed.append(me.position + Vector2(3, y))
		Vector2.DOWN:
			for x in range(-2, 3):
				changed.append(me.position + Vector2(x, 0))
				changed.append(me.position + Vector2(x, -7))
			for y in range(0, 8):
				changed.append(me.position + Vector2(-3, y))
				changed.append(me.position + Vector2(3, y))
		Vector2.LEFT:
			for y in range(-2, 3):
				changed.append(me.position + Vector2(0, y))
				changed.append(me.position + Vector2(-7, y))
			for x in range(-7, 1):
				changed.append(me.position + Vector2(x, -3))
				changed.append(me.position + Vector2(x, 3))
		Vector2.RIGHT:
			for y in range(-2, 3):
				changed.append(me.position + Vector2(0, y))
				changed.append(me.position + Vector2(7, y))
			for x in range(0, 8):
				changed.append(me.position + Vector2(x, -3))
				changed.append(me.position + Vector2(x, 3))
	for p in changed:
		var terrian = map.get_blockCN_by_position(p)
		if not terrian in ["河流"]:
			continue
		var b = "river_94"
		var lb = map.get_blockCN_by_position(p + Vector2.LEFT)
		var rb = map.get_blockCN_by_position(p + Vector2.RIGHT)
		var ub = map.get_blockCN_by_position(p + Vector2.UP)
		var db = map.get_blockCN_by_position(p + Vector2.DOWN)
		var lf = lb == "河流" or lb in StaticManager.CITY_BLOCKS_CN
		var rf = rb == "河流" or rb in StaticManager.CITY_BLOCKS_CN
		var uf = ub == "河流" or ub in StaticManager.CITY_BLOCKS_CN
		var df = db == "河流" or db in StaticManager.CITY_BLOCKS_CN
		if p == Vector2(20, 10):
			pass
		if not lf and not rf:
			b = "river_3"
			if not uf:
				b = "river_103"
			if not df:
				b = "river_105"
		elif not lf:
			b = "river_26"
			if not uf:
				b = "river_10"
				if not df:
					b = "river_104"
			elif not df:
				b = "river_8"
		elif not rf:
			b = "river_27"
			if not uf:
				b = "river_11"
				if not df:
					b = "river_101"
			elif not df:
				b = "river_9"
		elif not uf:
			b = "river_25"
			if not df:
				b = "river_2"
		elif not df:
			b = "river_24"
		map.set_temp_block(p, b, 2)

	var schemeTargets = []
	for wa in affected:
		schemeTargets.append(wa.actorId)
	if affected.size() > 0:
		var se = DataManager.new_stratagem_execution(actorId, "乱水", ske.skill_name)
		se.set_target(affected[0].actorId)
		se.perform_to_targets(schemeTargets, true)
		var moral = actor._get_attr_int_original("德") - affected.size()
		actor.set_moral(moral)
		var msg = "德降为<r{0}>".format([actor.get_moral()])
		ske.append_message(msg, actorId)
	else:
		# 模拟空放计策，以便接住后续判断
		var se = DataManager.new_stratagem_execution(actorId, "乱水", ske.skill_name)

	for wa in affected:
		ske.set_war_buff(wa.actorId, "疲兵", 1 + randi() % 2)

	map.aStar.update_map_for_actor(me)
	ske.cost_war_cd(99999)
	ske.cost_ap(COST_AP, true)

	if isAI:
		report_skill_result_message(ske, nextViewModel)
		return

	var msg = "掘开堤防，洪流无情！"
	ske.play_war_animation(ANIM, nextViewModel, -1, msg, 2)
	return
