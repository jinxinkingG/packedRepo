extends "effect_20000.gd"

# 暗遣主动技 #计策
#【暗遣】大战场，主动技。你可以指定一个树林地形，视为你在此处使用计策“十面埋伏”，每回合限1次。

const EFFECT_ID = 20586
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 8
const STRATAGEM = "要伏"

func effect_20586_start() -> void:
	if not assert_action_point(me.actorId, COST_AP):
		return
	var positions = []
	var radius = get_choose_distance()
	var left = max(0, me.position.x - radius)
	var right = min(map.cell_columns - 1, me.position.x + radius)
	var top = max(0, me.position.y - radius)
	var bottom = min(map.cell_rows - 2, me.position.y + radius)
	for x in range(left, right + 1):
		for y in range(top, bottom + 1):
			var pos = Vector2(x, y)
			var terrian = map.get_blockCN_by_position(pos)
			if not terrian in ["树林", "山地"]:
				continue
			positions.append(pos)
	if positions.empty():
		var msg = "附近没有合适的地形\n【{0}】只能于树林和山地发动".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return
	map.clear_can_choose_actors()
	map.show_color_block_by_position(positions)
	DataManager.set_env("可选目标", positions)
	DataManager.set_target_position(positions[0])
	SceneManager.show_unconfirm_dialog("于何处埋伏？", actorId)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_position(FLOW_BASE + "_selected")
	return

func effect_20586_selected() -> void:
	var pos = DataManager.get_target_position()
	var se = DataManager.new_stratagem_execution(actorId, STRATAGEM)
	var error = se.stratagem.check_area_correct(se.fromId, pos, true)
	if error != "":
		play_dialog(actorId, error, 3, 2999)
		return

	var msg = "消耗{0}机动力\n于险要之处设伏\n可否？".format([COST_AP])
	play_dialog(actorId, msg, 2, 2001, true)
	map.show_color_block_by_position(se.get_affected_positions(me.position))
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20586_confirmed() -> void:
	var pos = DataManager.get_target_position()
	var se = DataManager.get_current_stratagem_execution()
	se.set_target(-1)
	map.clear_can_choose_actors()
	map.next_shrink_actors = []
	map.show_color_block_by_position(se.get_affected_positions(pos))
	
	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	ske.war_report()

	se.perform_to_area(pos)
	se.report()

	ske.play_se_animation(se, 2003)
	return

func on_view_model_2003() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20586_report() -> void:
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 2003)
	return
