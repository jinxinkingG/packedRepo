extends "effect_20000.gd"

#水伏主动技 #计策
#【水伏】大战场，主动技。你在河流地形中的场合，消耗8机动力才能发动。在周围5*5的范围内水域中埋伏水性极好的士兵，敌方首次路过时，将会受到士兵伤害。（伤害公式和十面埋伏一样即可）

const EFFECT_ID = 20425
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 8
const STRATAGEM = "水伏"

func effect_20425_start():
	if not assert_action_point(me.actorId, COST_AP):
		return
	var terrian = map.get_blockCN_by_position(me.position)
	if terrian != "河流":
		var msg = "【{0}】不可于{1}发动".format([ske.skill_name, terrian])
		play_dialog(actorId, msg, 3, 2999)
		return
	var se = DataManager.new_stratagem_execution(me.actorId, STRATAGEM)
	var error = se.stratagem.check_area_correct(se.fromId, me.position)
	if error != "":
		LoadControl._error(error, se.fromId)
		return

	var msg = "消耗{0}机动力\n于附近水域设伏\n可否？".format([COST_AP])
	play_dialog(actorId, msg, 2, 2000, true)
	map.show_color_block_by_position(se.get_affected_positions(me.position))
	return

func on_view_model_2000()->void:
	wait_for_yesno(FLOW_BASE + "_2")
	return

func effect_20425_2():
	var se = DataManager.get_current_stratagem_execution()
	se.set_target(-1)
	map.clear_can_choose_actors()
	map.next_shrink_actors = []
	map.show_color_block_by_position(se.get_affected_positions(me.position))
	
	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	ske.war_report()

	se.perform_to_area(me.position)
	se.report()

	ske.play_se_animation(se, 2002)
	return

func on_view_model_2002()->void:
	wait_for_pending_message(FLOW_BASE + "_3")
	return

func effect_20425_3():
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 2002)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return
