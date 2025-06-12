extends "effect_20000.gd"

#走石主动技 #道术
#【走石】大战场，主动技。①你选择一个方向，消耗8点机动力。对该方向3×7区域内的所有对方单位造成道术 {走石} 伤害。并有30%概率，附加1回合 {疲兵} 状态。②你为张宝，则额外附加<激石>。

const EFFECT_ID = 20349
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 8
const STRATAGEM = "走石"

func check_AI_perform_20000()->bool:
	# AI 发动条件：机动力充足、范围内有合理目标
	if me.action_point < COST_AP:
		return false
	var targets = _get_available_target_positions(me)
	return not targets.empty()

func on_view_model_2000():
	wait_for_choose_position(FLOW_BASE + "_2")
	var se = DataManager.get_current_stratagem_execution()
	var pos = DataManager.get_target_position()
	map.set_cursor_location(pos, true)
	map.show_color_block_by_position(se.get_affected_positions(pos))
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

func effect_20349_AI_start():
	var se = DataManager.new_stratagem_execution(me.actorId, STRATAGEM)
	var targets = _get_available_target_positions(me)
	var target = targets[0]
	DataManager.set_target_position(target)
	map.set_cursor_location(target, true)
	map.show_color_block_by_position(se.get_affected_positions(target))
	
	var msg = "{0}发动{1}术".format([me.get_name(), STRATAGEM])
	play_dialog(se.targetId, msg, 2, 3000)
	map.next_shrink_actors = [me.actorId, se.targetId]
	return

func effect_20349_AI_2():
	_perform_skill(true, 3001)
	return

func effect_20349_AI_3():
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 3001)
	return

func effect_20349_start():
	var se = DataManager.new_stratagem_execution(me.actorId, STRATAGEM)
	if not assert_action_point(me.actorId, COST_AP):
		return
	var targets = _get_available_target_positions(me)
	if targets.empty():
		var msg = "没有合适的【{0}】发动点".format([ske.skill_name])
		play_dialog(me.actorId, msg, 3, 2009)
		return
	var msg = "选择【{0}】发动点".format([ske.skill_name])

	map.set_cursor_location(targets[0], true)
	map.show_color_block_by_position(targets);
	SceneManager.show_unconfirm_dialog(msg)
	set_env("可选目标", targets)
	DataManager.set_target_position(targets[0])
	map.show_color_block_by_position(se.get_affected_positions(targets[0]))
	LoadControl.set_view_model(2000)
	return

func effect_20349_2():
	var se = DataManager.get_current_stratagem_execution()
	var target = DataManager.get_target_position()
	var targets = se.get_affected_actors(target)
	if targets.empty():
		var msg = "当前没有可施放【{0}】的目标".format([ske.skill_name])
		play_dialog(me.actorId, msg, 3, 2009)
		return
	se.set_target(targets[0])
	var targetWA = DataManager.get_war_actor(targets[0])
	map.show_color_block_by_position(se.get_affected_positions(target))
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

func effect_20349_3():
	map.clear_can_choose_actors()
	map.next_shrink_actors = []
	_perform_skill(false, 2002)
	return

func effect_20349_4():
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 2002)
	return

func _get_available_target_positions(me:War_Actor)->PoolVector2Array:
	var se = StratagemExecution.new(me.actorId, STRATAGEM)
	var availables = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = me.position + dir
		var affected = se.get_affected_actors(pos).size()
		if affected == 0:
			continue
		var appended = false
		for i in availables.size():
			if availables[i][1] < affected:
				availables.insert(i, [pos, affected])
				appended = true
				break
		if not appended:
			availables.append([pos, affected])
	var ret = []
	for a in availables:
		ret.append(a[0])
	return ret

func _perform_skill(isAI:bool, nextViewModel:int=-1)->void:
	var se = DataManager.get_current_stratagem_execution()
	var target = DataManager.get_target_position()
	
	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	ske.war_report()

	var targets = se.get_affected_actors(target)
	se.set_target(targets[0])
	se.perform_to_targets(targets)
	se.report()

	if isAI:
		report_stratagem_result_message(se, nextViewModel)
		return

	ske.play_se_animation(se, nextViewModel, "", 0)
	return
