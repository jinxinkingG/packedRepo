extends "effect_30002.gd"

#骑突主动技
#【骑突】小战场，主动技。消耗5点战术值发动。你可跃马向前到三格以内且有敌军环绕的位置，并立刻对周围敌兵展开一次<冲阵>攻击。白刃战限1次。

const FLOW_BASE = "effect_" + str(QITU_EFFECT_ID)

const JUMP_RANGE = 3
const COST_TP = 5

const CHONGZHEN_EFFECT_ID = 30002

func on_view_model_2000()->void:
	wait_for_select_position(FLOW_BASE + "_2", FLOW_BASE + "_end")
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_end", false)
	return

func effect_30208_start()->void:
	if me.battle_tactic_point < COST_TP:
		var msg = "战术点不足\n【{0}】需战术点 >= {1}".format([
			ske.skill_name, COST_TP,
		])
		SceneManager.show_confirm_dialog(msg, me.actorId, 3)
		LoadControl.set_view_model(2999)
		return
	var positions = get_avaible_positions()
	if positions.empty():
		var msg = "没有可发动【{0}】的位置\n目标地点需为{1}格以内空位，且周围有敌军".format([
			ske.skill_name, JUMP_RANGE,
		])
		SceneManager.show_confirm_dialog(msg, me.actorId, 3)
		LoadControl.set_view_model(2999)
		return
	var sceneBattle = SceneManager.current_scene()
	sceneBattle.battle_tactic.hide()
	sceneBattle.move_cursor_to(positions[0])
	sceneBattle.mark_selectable_positions(positions)
	var msg = "请选择【{0}】目标地点".format([
		ske.skill_name,
	])
	SceneManager.show_unconfirm_dialog(msg, me.actorId, 2)
	LoadControl.set_view_model(2000)
	return

func effect_30208_2():
	var sceneBattle = SceneManager.current_scene()
	var positions = get_avaible_positions()
	var pos = sceneBattle.cursor_position
	if not pos in positions:
		goto_step("end")
		return
	var actorUnit = me.battle_actor_unit()
	actorUnit.unit_position = pos
	actorUnit.requires_update = true
	ske.set_battle_skill_val(1, 1, QITU_EFFECT_ID)
	ske.battle_change_tactic_point(-COST_TP, me)
	ske.battle_cd(99999)
	ske.battle_report()

	# 重新更新冲阵身周单位
	ske.set_battle_skill_val(null, 0, EFFECT_ID)
	update_target_units(actorUnit)
	var targetDic = get_next_atk_unit()
	if targetDic.empty():
		goto_step("end")
		return

	var targetId = int(targetDic["unitId"])
	var targetUnit = get_battle_unit(targetId)
	actorUnit.append_once_attack_tag("骑突", 9)
	var bia = Battle_Instant_Action.new()
	bia.unitId = actorUnit.unitId
	bia.action = "攻击"
	bia.targetUnitId = targetId
	bia.targetPos = targetUnit.unit_position
	bia.actionTimes = 1
	bia.targets = []
	bia.insert_to_env()
	mark_target_attacked(targetId)

	goto_step("end")
	return

func effect_30208_end():
	var sceneBattle = SceneManager.current_scene()
	sceneBattle.hide_cursor()
	sceneBattle.mark_selectable_positions([])
	LoadControl.load_script("res://resource/sgz_script/battle/player_tactic.gd")
	FlowManager.add_flow("tactic_end")
	return

func get_avaible_positions()->PoolVector2Array:
	var sceneBattle = SceneManager.current_scene()
	var ret = []
	var detected = {}
	var actorUnit = me.battle_actor_unit()
	if actorUnit == null:
		return ret
	for xDiff in JUMP_RANGE:
		var diff = Vector2(xDiff + 1, 0)
		var pos = actorUnit.unit_position + diff
		if actorUnit.get_side() == Vector2.RIGHT:
			pos = actorUnit.unit_position - diff
		if not sceneBattle.valid_unit_position(pos):
			continue
		if not actorUnit.can_move_to_position(pos):
			continue
		for dir in StaticManager.NEARBY_DIRECTIONS:
			var p = pos + dir
			if not p in detected:
				var unit = DataManager.get_battle_unit_by_position(p)
				detected[p] = unit
			var unit = detected[p]
			if unit == null or unit.disabled:
				continue
			if unit.leaderId < 0 or unit.leaderId == me.actorId:
				continue
			ret.append(pos)
			break
	return ret

