extends "effect_20000.gd"

# 惊涛主动技
#【惊涛】大战场，主将主动技。消耗10点机动力，视为对全地图水地形中的敌军，分别使用一次乱水。每回合限1次。

const EFFECT_ID = 20599
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 10
const STRATAGEM = "乱水"

func check_AI_perform_20000() -> bool:
	if me.action_point < COST_AP:
		return false
	var targetIds = []
	for enemy in me.get_enemy_war_actors(true):
		var terrian = map.get_blockCN_by_position(enemy.position)
		if terrian != "河流":
			continue
		targetIds.append(enemy.actorId)
	return targetIds.size() >= 2

func effect_20599_AI_start() -> void:
	goto_step("confirmed")
	return

func effect_20599_start() -> void:
	if not assert_action_point(actorId, COST_AP):
		return
	var targetNames = []
	var targetIds = []
	for enemy in me.get_enemy_war_actors(true):
		var terrian = map.get_blockCN_by_position(enemy.position)
		if terrian != "河流":
			continue
		targetIds.append(enemy.actorId)
		targetNames.append(enemy.get_name())
	if targetIds.empty():
		var msg = "没有可以发动【{0}】的目标".format([ske.skill_name])
		play_dialog(actorId, msg, 2, 2999)
		return
	var msg = "消耗 {0} 机动力\n对{1}等{2}敌军发动【{3}】\n可否？"
	if targetNames.size() == 1:
		msg = "消耗 {0} 机动力\n对{1}发动【{3}】\n可否？"
	msg = msg.format([
		COST_AP, targetNames[0], targetNames.size(), ske.skill_name,
	])
	map.show_can_choose_actors(targetIds)
	play_dialog(actorId, msg, 2, 2000, true)
	map.next_shrink_actors = targetIds
	map.next_shrink_actors.append(actorId)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20599_confirmed() -> void:
	var se = DataManager.new_stratagem_execution(actorId, STRATAGEM, ske.skill_name)
	var targetIds = []
	for enemy in me.get_enemy_war_actors(true):
		var terrian = map.get_blockCN_by_position(enemy.position)
		if terrian != "河流":
			continue
		targetIds.append(enemy.actorId)

	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	ske.war_report()

	se.set_target(-1)
	# 距离视为 1
	var distanceSetting = {"乱水": {"固定": 1}}
	DataManager.set_env("计策.ONCE.距离", distanceSetting)
	se.perform_to_targets(targetIds)
	se.report()
	var msg = "大江之上，谁敢争锋！"
	map.draw_actors()
	
	# 执行完后设置一下 target 是为了汇报方便，如果是 AI 发动的话
	se.set_target(targetIds[0])
	
	ske.play_se_animation(se, 2001, msg, 0)
	map.next_shrink_actors = se.get_all_damaged_targets()
	return

func on_view_model_2001()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_report")
	return

func effect_20599_report():
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 2002)
	return

func on_view_model_2002()->void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return
