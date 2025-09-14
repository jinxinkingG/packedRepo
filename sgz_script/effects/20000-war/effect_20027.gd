extends "effect_20000.gd"

#酒计诱发后锁定效果
#【酒计】大战场，诱发技。你被使用伤兵计的场合，若施计者不在太守府，你可以发动：本次计策必中，施计者与你进入白刃战，若本次白刃战你取得胜利，你恢复本回合被计策伤害的全部兵力，回合外限1次。

const EFFECT_ID = 20027
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const INDUCE_EFFECT_ID = 20025

func on_trigger_20012()->bool:
	var se = DataManager.get_current_stratagem_execution()
	var fromId = se.get_action_id(actorId)
	if fromId < 0:
		return false
	if se.succeeded <= 0:
		return false
	if se.targetId != actorId:
		return false
	if not se.damage_soldier():
		return false
	if ske.get_war_skill_val_int(INDUCE_EFFECT_ID) <= 0:
		return false
	ske.set_war_skill_val(0, 0, INDUCE_EFFECT_ID)
	return true

func effect_20027_AI_start()->void:
	goto_step("start")
	return

func effect_20027_start()->void:
	ske.cost_war_cd(1)
	var se = DataManager.get_current_stratagem_execution()
	if se.will_auto_finish_turn():
		ske.mark_auto_finish_turn()
	var fromId = se.get_action_id(actorId)
	var msg = "{0}果然贪酒！\n全军出击！".format([actor.get_name()])
	play_dialog(fromId, msg, 0, 2000)
	return

func on_view_model_2001()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_20027_2()->void:
	var se = DataManager.get_current_stratagem_execution()
	var fromId = se.get_action_id(actorId)
	var msg = "哈哈哈哈！\n{0}！中吾计也！".format([
		DataManager.get_actor_naughty_title(fromId, actorId),
	])
	play_dialog(actorId, msg, 1, 2001)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20027_3()->void:
	var se = DataManager.get_current_stratagem_execution()
	var fromId = se.get_action_id(actorId)
	ske.cost_war_cd(1)
	se.report()
	start_battle_and_finish(fromId, actorId, ske.skill_name, actorId)
	return
