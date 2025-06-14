extends "effect_20000.gd"

# 谋诛主动技
#【谋诛】大战场，主动技。每回合限1次，你可消耗所有机动力，选一个执行：①无视地形移动1步。②与一名相邻敌将进入白刃战。

const EFFECT_ID = 20610
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20610_start() -> void:
	if not assert_action_point(actorId, 1):
		return
	var positions = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = me.position + dir
		if not map.is_valid_position(pos):
			continue
		var wa = DataManager.get_war_actor_by_position(pos)
		if wa != null and not me.is_enemy(wa):
			continue
		positions.append(pos)
	if positions.empty():
		var msg = "没有可以【{0}】的位置".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return
	map.clear_can_choose_actors()
	map.show_color_block_by_position(positions)
	DataManager.set_env("可选目标", positions)
	DataManager.set_target_position(positions[0])
	SceneManager.show_unconfirm_dialog("目标何处？", actorId)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_position(FLOW_BASE + "_selected")
	return

func effect_20610_selected()->void:
	var pos = DataManager.get_target_position()
	var wa = DataManager.get_war_actor_by_position(pos)
	var msg = "消耗全部机动力\n移动到目标位置\n可否？"
	var actors = [actorId]
	if wa != null and not wa.disabled:
		msg = "消耗全部机动力\n攻击{0}\n可否？".format([
			wa.get_name(),
		])
		actors = [wa.actorId, actorId]
	play_dialog(actorId, msg, 2, 2001, true)
	map.next_shrink_actors = actors
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20610_confirmed() -> void:
	var pos = DataManager.get_target_position()
	var wa = DataManager.get_war_actor_by_position(pos)

	ske.cost_ap(me.action_point, true)
	ske.cost_war_cd(1)

	map.show_color_block_by_position([])
	if wa == null or wa.disabled:
		# 没人，无条件移动过去
		ske.change_war_actor_position(actorId, pos)
		ske.war_report()
		var msg = "杀出血路！"
		play_dialog(actorId, msg, 2, 2999)
		return
	# 有人，跳攻
	var msg = "挡我者斩！".format([
		DataManager.get_actor_naughty_title(wa.actorId, actorId),
	])
	play_dialog(actorId, msg, 0, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_fight")
	return

func effect_20610_fight() -> void:
	var pos = DataManager.get_target_position()
	var wa = DataManager.get_war_actor_by_position(pos)
	var val = [wa.actorId, pos.x, pos.y]
	ske.set_war_skill_val(val, 1)
	map.next_shrink_actors = []
	start_battle_and_finish(actorId, wa.actorId)
	return
