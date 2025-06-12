extends "effect_20000.gd"

#义气锁定技
#【义气】大战场，锁定技。你的兵力＞1000时，与你距离3以内的己方武将，受到计策伤害时，你与其共同平分伤害。

const EFFECT_ID = 20385
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000():
	wait_for_pending_message(FLOW_BASE + "_2", "")
	return

func on_view_model_2001():
	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20385_AI_start():
	goto_step("start")
	return

func effect_20385_start():
	var se = DataManager.get_current_stratagem_execution()
	var totalDamage = 0
	var found = []
	for targetId in se.get_all_damaged_targets():
		var wa = DataManager.get_war_actor(targetId)
		if not me.is_teammate(wa):
			continue
		if Global.get_range_distance(wa.position, me.position) > 3:
			continue
		found.append(targetId)
		totalDamage += se.get_soldier_damage_for(targetId)
	if found.empty() or totalDamage <= 0:
		skill_end_clear()
		return

	totalDamage = min(totalDamage, actor.get_soldiers() / 2)
	totalDamage = int(totalDamage / 2)
	var recoveredEach = int(totalDamage / found.size())
	for targetId in found:
		ske.change_actor_soldiers(targetId, recoveredEach)
	ske.change_actor_soldiers(me.actorId, -totalDamage)
	var msg = "同袍之义，理所当然"
	report_skill_result_message(ske, 2000, msg)
	return

func effect_20385_2():
	report_skill_result_message(ske, 2000)
	return

func on_trigger_20012()->bool:
	if actor.get_soldiers() < 1000:
		return false
	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	var found = false
	for targetId in se.get_all_damaged_targets():
		var wa = DataManager.get_war_actor(targetId)
		if not me.is_teammate(wa):
			continue
		if Global.get_range_distance(wa.position, me.position) > 3:
			continue
		found = true
		break
	if not found:
		return false
	return true
