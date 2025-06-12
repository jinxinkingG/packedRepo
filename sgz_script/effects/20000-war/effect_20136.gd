extends "effect_20000.gd"

#呼风主动技 #道术
#【呼风】大战场，主动技。①你可以选择距离8以内某个对方武将，以该敌将为中心5×5范围内，发动道术，使范围内所有单位随机排列。每个回合限1次。②你为诸葛亮，则可以指定风向。（八个风向）

const EFFECT_ID = 20136
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 0
const STRATAGEM = "呼风"

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

func effect_20136_AI_start():
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

func effect_20136_AI_2():
	_perform_skill(true, 3001)
	return

func effect_20136_AI_3():
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 3001)
	return

func effect_20136_start():
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

func effect_20136_2():
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

func effect_20136_3():
	map.clear_can_choose_actors()
	map.next_shrink_actors = []
	_perform_skill(false, 2002)
	return

func effect_20136_4():
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 2002)
	return

func _get_available_targets(me:War_Actor)->PoolIntArray:
	return get_enemy_targets(me, false)

func _perform_skill(isAI:bool, nextViewModel:int=-1)->void:
	var se = DataManager.get_current_stratagem_execution()
	var targetWA = DataManager.get_war_actor(se.targetId)

	if actorId == StaticManager.ACTOR_ID_ZHUGELIANG:
		if se.get_env_int("风向X", 99) == 99:
			# 未设定风向
			if me.get_controlNo() < 0:
				# AI 总是往远处吹
				var disv = targetWA.position - me.position
				disv.x = 0 if disv.x == 0 else -1 if disv.x < 0 else 1
				disv.y = 0 if disv.y == 0 else -1 if disv.y < 0 else 1
				se.set_env("风向X", int(disv.x))
				se.set_env("风向Y", int(disv.y))
			else:
				# 玩家选择
				var directions = []
				var values = []
				for i in StaticManager.ALL_DIRECTIONS.size():
					var dir = StaticManager.ALL_DIRECTIONS[i]
					if dir == Vector2.ZERO:
						directions.append("")
						values.append(-1)
						continue
					directions.append(StaticManager.ALL_DIRECTION_NAMES[i])
					values.append(i)
				SceneManager.show_unconfirm_dialog("天地之机，亦在吾算中\n风往哪里吹？", actorId)
				SceneManager.bind_top_menu(directions, values, 3, Vector2(40, 20), Vector2(160, 60))
				LoadControl.set_view_model(2500)
				return
	
	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	ske.war_report()

	var targets = se.get_affected_actors(targetWA.position)
	se.perform_to_targets(targets, true)
	se.report()

	if isAI:
		report_stratagem_result_message(se, nextViewModel)
		return

	ske.play_se_animation(se, nextViewModel)
	return

func on_view_model_2500() -> void:
	wait_for_choose_item(FLOW_BASE + "_direction")
	return

func effect_20136_direction() -> void:
	var option = DataManager.get_env_int("目标项")
	if option >= 0 and option < StaticManager.ALL_DIRECTIONS.size():
		var se = DataManager.get_current_stratagem_execution()
		var dir = StaticManager.ALL_DIRECTIONS[option]
		se.set_env("风向X", dir.x)
		se.set_env("风向Y", dir.y)
	goto_step("3")
	return
