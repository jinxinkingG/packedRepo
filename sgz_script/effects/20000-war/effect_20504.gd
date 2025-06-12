extends "effect_20000.gd"

#诱伏主动技
#【诱伏】大战场，主动技。你处于 {定止} 状态时，可以发动：消耗50兵力，解除你的定止状态，并施展一次十面埋伏。

const EFFECT_ID = 20504
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_SOLDIERS = 50

func check_AI_perform_20000()->bool:
	if me.get_soldiers() < COST_SOLDIERS:
		return false
	return me.get_buff("定止")["回合数"] > 0

func effect_20504_AI_start()->void:
	goto_step("go")
	return

func effect_20504_start()->void:
	if me.get_buff("定止")["回合数"] <= 0:
		var msg = "并未处于[定止]状态"
		play_dialog(actorId, msg, 2, 2999)
		return
	if me.get_soldiers() < COST_SOLDIERS:
		var msg = "兵力不足，需 >= {0}".format([COST_SOLDIERS])
		play_dialog(actorId, msg, 3, 2999)
		return
	var msg = "牺牲{0}士兵发动【{1}】\n解除定止"
	var terrian = map.get_blockCN_by_position(me.position)
	if terrian == "树林":
		msg += "，并发动十面埋伏"
	msg += "\n可否？"
	msg = msg.format([COST_SOLDIERS, ske.skill_name])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000()->void:
	wait_for_yesno(FLOW_BASE + "_go")
	return

func effect_20504_go()->void:
	ske.remove_war_buff(actorId, "定止")
	ske.change_actor_soldiers(actorId, -COST_SOLDIERS)
	map.draw_actors()
	ske.war_report()

	var terrian = map.get_blockCN_by_position(me.position)
	if terrian != "树林":
		var msg = "断尾求生，速离险地！"
		if me.get_controlNo() < 0:
			msg += "\n（发动【{0}】解除定止".format([ske.skill_name])
		play_dialog(actorId, msg, 0, 2999)
		return

	var se = DataManager.new_stratagem_execution(actorId, "十面埋伏", ske.skill_name)
	se.perform_to_area(me.position)
	var msg = "断尾求生，设伏反制！"
	if me.get_controlNo() < 0:
		msg += "\n（发动【{0}】解除定止\n（同时设下埋伏".format([ske.skill_name])
	ske.play_se_animation(se, 2001, msg)
	return

func on_view_model_2001()->void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20504_report()->void:
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 2001)
	return
