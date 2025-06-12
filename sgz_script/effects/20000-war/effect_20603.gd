extends "effect_20000.gd"

# 接应主动技
#【接应】大战场，主动技。消耗6点机动力，指定一个队友，与之交换位置。交换后，若你身边有敌军，必须选择一个与之进入白刃战。每回合限1次。

const EFFECT_ID = 20603
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 6

func effect_20603_start() -> void:
	if not assert_action_point(actorId, COST_AP):
		return
	var targetIds = get_teammate_targets(me)
	if targetIds.empty():
		var msg = "没有可以发动【{0}】的队友".format([
			ske.skill_name
		])
		play_dialog(actorId, msg, 2, 2999)
		return
	var msg = "选择队友发动【{0}】".format([ske.skill_name])
	if not wait_choose_actors(targetIds, msg):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20603_selected() -> void:
	var targetId = DataManager.get_env_int("目标")

	var msg = "消耗 {0} 机动力\n【{1}】{2}\n可否？".format([
		COST_AP, ske.skill_name,
		ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20603_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")

	ske.cost_ap(COST_AP, true)
	ske.cost_war_cd(1)
	ske.swap_war_actor_positions(actorId, targetId)
	ske.war_report()

	var msg = "{0}，换防\n此地放心交予在下".format([
		DataManager.get_actor_honored_title(targetId, actorId)
	])
	map.draw_actors()
	play_dialog(actorId, msg, 2, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_yesno(FLOW_BASE + "_check")
	return

func effect_20603_check() -> void:
	var targetIds = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = me.position + dir
		var target = DataManager.get_war_actor_by_position(pos)
		if me.is_enemy(target):
			targetIds.append(target.actorId)
	if targetIds.empty():
		skill_end_clear()
		FlowManager.add_flow("player_skill_end_trigger")
		return
	var msg = "选择攻击目标"
	if not wait_choose_actors(targetIds, msg):
		msg = "没有可攻击的目标"
		play_dialog(actorId, msg, 3, 2999)
		return
	LoadControl.set_view_model(2003)
	return

func on_view_model_2003() -> void:
	wait_for_choose_actor(FLOW_BASE + "_targeted", true, false)
	return

func effect_20603_targeted() -> void:
	var targetId = DataManager.get_env_int("目标")
	var leaderId = me.get_main_actor_id()

	var msg = "{0}妙算\n{1}可知{2}在此！".format([
		DataManager.get_actor_honored_title(leaderId, actorId),
		DataManager.get_actor_naughty_title(targetId, actorId),
		DataManager.get_actor_self_title(actorId)
	])
	play_dialog(actorId, msg, 0, 2004)
	map.next_shrink_actors = [actorId, targetId]
	return

func on_view_model_2004() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_fight")
	return

func effect_20603_fight() -> void:
	map.next_shrink_actors = []
	var targetId = DataManager.get_env_int("目标")
	start_battle_and_finish(actorId, targetId)
	return
