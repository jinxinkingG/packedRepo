extends "effect_30000.gd"

# 回跃主动技 #恢复体力
#【回跃】小战场，主动技。消耗5点战术值发动。你可跃马向后，退到三格以后。体力+8，白刃战限1次

const EFFECT_ID = 30295
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_TP = 5
const BUFF_HP = 8

func effect_30295_start() -> void:
	if me.battle_tactic_point < COST_TP:
		var msg = "战术点不足\n【{0}】需战术点 >= {1}".format([
			ske.skill_name, COST_TP,
		])
		SceneManager.show_confirm_dialog(msg, actorId, 3)
		LoadControl.set_view_model(2000)
		return
	var actorUnit = me.battle_actor_unit()
	if actorUnit == null:
		var msg = "不可！"
		SceneManager.show_confirm_dialog(msg, actorId, 2)
		LoadControl.set_view_model(2000)
		return
	var pos = actorUnit.unit_position + actorUnit.get_side() * 3
	if not actorUnit.can_move_to_position(pos):
		var msg = "无法回跃到目标位置！"
		SceneManager.show_confirm_dialog(msg, actorId, 2)
		LoadControl.set_view_model(2000)
		return

	actorUnit.unit_position = pos
	actorUnit.requires_update = true
	ske.battle_change_tactic_point(-COST_TP)
	var recovered = ske.battle_change_unit_hp(actorUnit, BUFF_HP)
	var status = "{0} +{1}".format([
		ske.skill_name, recovered
	])
	actorUnit.add_status_effect(status)
	ske.battle_cd(99999)
	goto_step("end")
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_end", false)
	return

func effect_30295_end()->void:
	tactic_end()
	return
