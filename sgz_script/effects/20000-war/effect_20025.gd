extends "effect_20000.gd"

#酒计诱发部分
#【酒计】大战场，诱发技。你被使用伤兵计的场合，若施计者不在太守府，你可以发动：本次计策必中，施计者与你进入白刃战，若本次白刃战你取得胜利，你恢复本回合被计策伤害的全部兵力，回合外限1次。

const EFFECT_ID = 20025
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20038()->bool:
	var se = DataManager.get_current_stratagem_execution()
	var fromId = se.get_action_id(actorId)
	if fromId < 0:
		return false
	if se.targetId != actorId:
		return false
	if not se.damage_soldier():
		return false
	# 太守府不会被引诱出击
	var wa = DataManager.get_war_actor(fromId)
	var terrian = map.get_blockCN_by_position(wa.position)
	if terrian in ["太守府"]:
		return false
	# 不可触发战斗的，也要排除
	if check_combat_targets([fromId]).empty():
		return false
	return true

func effect_20025_AI_start()->void:
	goto_step("start")
	return

func effect_20025_start()->void:
	var se = DataManager.get_current_stratagem_execution()
	se.set_must_success(actorId, ske.skill_name)
	se.skip_redo = 1
	se.goback_disabled = 1
	ske.set_war_skill_val(1, 1)
	ske.cost_war_cd(1)
	var fromId = se.get_action_id(actorId)
	var msg = "{0}以某为无谋之辈！".format([
		DataManager.get_actor_naughty_title(fromId, actorId),
	])
	play_dialog(actorId, msg, 2, 2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation("")
	return
