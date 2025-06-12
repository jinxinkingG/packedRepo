extends "effect_20000.gd"

#临征限定技 #回复兵力
#【临征】大战场，限定技。你可以消耗100金，兵力+400，并在战争结束后遣散之。

const EFFECT_ID = 20345
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_GOLD = 100
const RECOVER_SOLDIERS = 400

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

func on_view_model_2009():
	wait_for_pending_message(FLOW_BASE + "_3")
	return

func on_view_model_3009():
	wait_for_pending_message(FLOW_BASE + "_AI_2", "AI_before_ready")
	return

func check_AI_perform_20000()->bool:
	var wv = me.war_vstate()
	if wv.money < COST_GOLD:
		return false
	var maxSoldiers = DataManager.get_actor_max_soldiers(me.actorId)
	if me.get_soldiers() > maxSoldiers - RECOVER_SOLDIERS:
		return false
	# 提前 CD，避免异步执行造成反复调用
	ske.cost_war_cd(99999)
	return true

func effect_20345_AI_start():
	goto_step("2")
	return

func effect_20345_AI_2():
	report_skill_result_message(ske, 3009)
	return

# 发动主动技
func effect_20345_start():
	var wv = me.war_vstate()

	if wv.money < COST_GOLD:
		var msg = "金不足，发动【临征】需\n金 >= {0}".format([COST_GOLD])
		play_dialog(me.actorId, msg, 3, 2009)
		return

	var maxSoldiers = DataManager.get_actor_max_soldiers(me.actorId)
	if actor.get_soldiers() > maxSoldiers - RECOVER_SOLDIERS:
		var msg = "兵力充足，无须【临征】"
		play_dialog(me.actorId, msg, 2, 2009)
		return

	var msg = "消耗 {0} 金发动【临征】\n补充 {1} 兵力\n可否？".format([
		COST_GOLD, RECOVER_SOLDIERS,
	])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func effect_20345_2():
	ske.cost_war_cd(99999)
	ske.cost_wv_gold(COST_GOLD)
	ske.add_war_tmp_soldier(ske.skill_actorId, RECOVER_SOLDIERS, -1)

	var msg ="重赏之下，可有勇夫？"
	var vm = 2009
	if me.get_controlNo() < 0:
		vm = 3009
	report_skill_result_message(ske, vm, msg, 0)
	return

func effect_20345_3():
	report_skill_result_message(ske, 2009)
	return
