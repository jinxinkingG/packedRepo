extends "effect_20000.gd"

#唤雨主动技 #道术
#【唤雨】大战场,主动技。你可以消耗8机动力，指定一个武将，发动道术唤雨：目标周围2格距离内的己方武将体力+10，并对该范围内的对方武将附加1回合 {迟滞} 状态。每回合限1次。

const EFFECT_ID = 20231
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 8
const STRATAGEM = "唤雨"

func check_AI_perform_20000()->bool:
	# AI 发动条件：机动力充足、范围内有合理目标
	if me.action_point < COST_AP:
		return false
	var targets = _get_available_targets(me)
	return not targets.empty()

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	var targetId = get_env_int("武将")
	var se = DataManager.get_current_stratagem_execution()
	se.set_target(targetId)
	var targetWA = DataManager.get_war_actor(se.targetId)
	if targetWA != null:
		map.next_shrink_actors = [se.targetId]
		map.set_cursor_location(targetWA.position, true)
		map.show_color_block_by_position(se.get_affected_positions(targetWA.position))
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_4")
	return

func on_view_model_2009():
	wait_for_skill_result_confirmation()
	return

func on_view_model_3000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_AI_2")
	return

func on_view_model_3001():
	wait_for_pending_message(FLOW_BASE + "_AI_3", "AI_before_ready")
	return

func effect_20231_AI_start():
	var se = DataManager.new_stratagem_execution(me.actorId, STRATAGEM)
	var targets = _get_available_targets(me)
	se.set_target(targets[0])
	var targetWA = DataManager.get_war_actor(se.targetId)
	map.set_cursor_location(targetWA.position, true)
	map.show_color_block_by_position(se.get_affected_positions(targetWA.position))
	
	var msg = "{0}发动{1}术".format([me.get_name(), STRATAGEM])
	play_dialog(se.targetId, msg, 2, 3000)
	map.next_shrink_actors = [me.actorId, se.targetId]
	return

func effect_20231_AI_2():
	_perform_skill(true, 3001)
	return

func effect_20231_AI_3():
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 3001)
	return

func effect_20231_start():
	var se = DataManager.new_stratagem_execution(me.actorId, STRATAGEM)
	if not assert_action_point(me.actorId, COST_AP):
		return
	var targets = _get_available_targets(me)
	var msg = "选择【{0}】发动点".format([ske.skill_name])
	if not wait_choose_actors(targets, msg):
		return
	var targetId = get_env_int("武将")
	var targetWA = DataManager.get_war_actor(targetId)
	map.next_shrink_actors = [targetId]
	map.show_color_block_by_position(se.get_affected_positions(targetWA.position))
	LoadControl.set_view_model(2000)
	return

func effect_20231_2():
	var se = DataManager.get_current_stratagem_execution()
	se.set_target(get_env_int("目标"))
	var targetWA = DataManager.get_war_actor(se.targetId)
	var targets = se.get_affected_actors(targetWA.position)
	if targets.empty():
		var msg = "当前没有可施放【{0}】的目标".format([ske.skill_name])
		play_dialog(me.actorId, msg, 3, 2009)
		return
	map.show_color_block_by_position(se.get_affected_positions(targetWA.position))
	map.show_can_choose_actors(targets)
	var msg = "对{0}等{1}人发动【{2}】，可否？"
	if targets.size() == 1:
		msg = "对{0}发动【{2}】，可否？"
	msg = msg.format([
		targetWA.get_name(), targets.size(), ske.skill_name,
	])
	if COST_AP > 0:
		msg = "消耗{0}点机动力\n".format([COST_AP]) + msg
	# 不适用 play_dialog，尽可能维持计策范围显示
	SceneManager.show_yn_dialog(msg, me.actorId)
	LoadControl.set_view_model(2001)
	return

func effect_20231_3():
	map.clear_can_choose_actors()
	map.next_shrink_actors = []
	_perform_skill(false, 2002)
	return

func effect_20231_4():
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 2002)
	return

func _get_available_targets(me:War_Actor)->PoolIntArray:
	var map = SceneManager.current_scene().war_map
	var targets = get_enemy_targets(me)
	# 扩大两格检查有没有受伤的队友
	var teammates = get_teammate_targets(me, get_choose_distance() + 2)
	teammates.append(me.actorId)
	var candidates = {}
	var injuredOutside = {}
	for targetId in teammates:
		var wa = DataManager.get_war_actor(targetId)
		var disv = wa.position - me.position
		if max(abs(disv.x), abs(disv.y)) <= get_choose_distance():
			# 范围内的队友
			if wa.actor().is_injured():
				# 受伤，直接加入可选目标
				targets.append(targetId)
			else:
				# 未受伤，加入备选目标
				candidates[targetId] = wa.position
		else:
			if wa.actor().is_injured():
				# 范围外，已受伤，待检查
				injuredOutside[targetId] = wa.position
	for iid in injuredOutside:
		for cid in candidates:
			var disv = candidates[cid] - injuredOutside[iid]
			if max(abs(disv.x), abs(disv.y)) <= 2:
				targets.erase(cid)
				targets.append(cid)
				candidates.erase(cid)
				break
	return targets

func _perform_skill(isAI:bool, nextViewModel:int=-1)->void:
	var se = DataManager.get_current_stratagem_execution()
	var targetWA = DataManager.get_war_actor(se.targetId)
	
	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	ske.war_report()

	var targets = se.get_affected_actors(targetWA.position)
	se.perform_to_targets(targets)
	se.report()

	if isAI:
		report_stratagem_result_message(se, nextViewModel)
		return

	ske.play_se_animation(se, nextViewModel, "", 0)
	return
