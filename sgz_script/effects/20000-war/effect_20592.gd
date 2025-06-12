extends "effect_20000.gd"

# 过江主动技
#【过江】大战场，主动技。临江可发动，选择直线的江畔，若对岸非城地形，你可消耗5点机动力，直接位移至目标地点。

const EFFECT_ID = 20592
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 5

func on_trigger_20013() -> bool:
	ske.set_war_skill_val(0)
	return false

func effect_20592_start() -> void:
	if not assert_action_point(actorId, COST_AP):
		return
	var positions = get_possible_positions()
	if positions.empty():
		var msg = "没有可以【{0}】的目标位置".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return
	map.clear_can_choose_actors()
	map.show_color_block_by_position(positions)
	DataManager.set_env("可选目标", positions)
	DataManager.set_target_position(positions[0])
	var msg = "往何处【{0}】？".format([ske.skill_name])
	SceneManager.show_unconfirm_dialog(msg, actorId)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_position(FLOW_BASE + "_selected")
	return

func effect_20592_selected() -> void:
	var pos = DataManager.get_target_position()

	var msg = "消耗{0}机动力\n跨江而去\n可否？".format([COST_AP])
	play_dialog(actorId, msg, 2, 2001, true)
	map.show_color_block_by_position([pos])
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20592_confirmed() -> void:
	var pos = DataManager.get_target_position()
	map.clear_can_choose_actors()
	map.show_color_block_by_position([])

	ske.cost_ap(COST_AP, true)
	ske.set_war_skill_val(ske.get_war_skill_val_int() + 1)
	ske.change_war_actor_position(actorId, pos)
	ske.war_report()

	var msg = "{0}愿当先过江，一探究竟".format([
		actor.get_short_name()
	])
	play_dialog(actorId, msg, 1, 2999)
	return

func get_possible_positions() -> PoolVector2Array:
	var ret = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		for i in 99:
			var pos = me.position + (i + 1) * dir
			if not map.is_valid_position(pos):
				break
			var terrian = map.get_blockCN_by_position(pos)
			if terrian == "河流":
				continue
			if i <= 0:
				break
			if terrian in StaticManager.CITY_BLOCKS_CN:
				break
			var wa = DataManager.get_war_actor_by_position(pos)
			if wa != null:
				break
			ret.append(pos)
			break
	return ret
