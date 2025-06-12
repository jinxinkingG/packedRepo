extends "effect_30000.gd"

#水龙主动技
#【水龙】小战场，主动技。非攻城、非林地形，非山地形可以使用，消耗8点体力，以你前方6格距离的格子为中心，3×3范围内出现水浪。对水浪对范围内的每个对方士兵造成X点水龙伤害，并击退范围内士兵1格，X＝你的政×0.4，白刃战限1次。

const EFFECT_ID = 30274
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const HP_COST = 8

func effect_30274_start()->void:
	var unit = me.battle_actor_unit()
	if unit == null:
		tactic_end()
		return
	if unit.get_hp() <= HP_COST:
		var msg = "体力不足，需 > {0}".format([HP_COST])
		me.attach_free_dialog(msg, 3, 30000)
		tactic_end()
		return

	var center = unit.unit_position - unit.get_side() * 6
	var positions = []
	for dir in StaticManager.ALL_DIRECTIONS:
		positions.append(center + dir)
	var scene = SceneManager.current_scene()
	scene.battle_tactic.hide()
	scene.mark_selectable_positions(positions)

	ske.battle_cd(99999)
	SceneManager.show_confirm_dialog("玄冥怒涛！", actorId, 0)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_30274_2() -> void:
	var unit = me.battle_actor_unit()
	var scene = SceneManager.current_scene()
	scene.mark_selectable_positions([])

	ske.battle_change_unit_hp(unit, -HP_COST)
	unit.add_status_effect("-{0}#FF0000".format([HP_COST]))
	
	var center = unit.unit_position - unit.get_side() * 6
	var positions = [center]
	for dir in StaticManager.ALL_DIRECTIONS:
		positions.append(center + dir)
	
	var bf = DataManager.get_current_battle_fight()
	var candidates = []
	for bu in bf.battle_units(enemy.actorId):
		if bu.get_unit_type() in ["城门", "将"]:
			continue
		if not bu.unit_position in positions:
			continue
		candidates.append(bu)
		
	if candidates.empty():
		me.attach_free_dialog("…… ？！", 0, 30000)
		ske.battle_report()
		tactic_end()
		return

	var x = int(ceil(actor.get_politics() * 0.4))
	scene.play_flood(unit, candidates, x)
	ske.battle_report()

	# 群体击退
	var targetIds = []
	for bu in candidates:
		targetIds.append(bu.unitId)
	var bia = Battle_Instant_Action.new()
	bia.unitId = unit.unitId;
	bia.action = "迫退"
	bia.targetUnitId = -1
	bia.actionTimes = 1
	bia.targetPos = unit.get_side()
	bia.targets = targetIds
	bia.insert_to_env()

	tactic_end()
	return
