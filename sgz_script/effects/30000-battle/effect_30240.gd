extends "effect_30000.gd"

#三马主动技
#【三马】小战场，主动技。你的士兵单位不高于7个时，才能使用。你召唤3个兵力为100的骑兵单位，从战场后方杀出。每个大战场回合限1次。

const EFFECT_ID = 30240
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const UNIT_HP = 100

func check_AI_perform()->bool:
	var bf = DataManager.get_current_battle_fight()
	# 第三回合后、身后无人，开始发动
	if bf == null or bf.turns() <= 3:
		return false
	var total = 0
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled:
			continue
		if bu.leaderId == actorId:
			if not bu.get_unit_type() in ["将", "城门"]:
				total += 1
	if total > 7:
		return false
	var me = DataManager.get_war_actor(actorId)
	var unit = me.battle_actor_unit()
	return not get_available_positions(unit).empty()

func effect_30240_AI_start():
	goto_step("start")
	return

func effect_30240_start():
	var total = 0
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled:
			continue
		if bu.leaderId == actorId:
			if not bu.get_unit_type() in ["将", "城门"]:
				total += 1
	if total > 7:
		var msg = "已有{0}个士兵单位\n无法发动【{1}】".format([total, ske.skill_name])
		SceneManager.show_confirm_dialog(msg, actorId, 3)
		LoadControl.set_view_model(2000)
		return
	var unit = me.battle_actor_unit()
	var targets = []
	if unit != null:
		targets = get_available_positions(unit)
	if targets.empty():
		var msg = "无可用位置"
		SceneManager.show_confirm_dialog(msg, actorId, 3)
		LoadControl.set_view_model(2000)
		return
	goto_step("2")
	return

func effect_30240_2():
	var unit = get_leader_unit(me.actorId)
	var positions = get_available_positions(unit)

	ske.battle_cd(99999)
	ske.cost_war_cd(1)
	for pos in positions:
		var bu = Battle_Unit.new(actorId)
		bu.unitId = DataManager.battle_units.size()
		bu.direction = unit.direction
		bu._private_hp = UNIT_HP
		bu.disabled = false
		bu.unit_position = pos
		bu.init_combat_info("骑")
		bu.wait_action_times = bu.get_action_times()
		bu.dic_other_variable["临时"] = 1
		DataManager.battle_units.append(bu)
		SceneManager.current_scene().create_or_update_unit(bu)

	ske.battle_report()

	SceneManager.current_scene().battle_tactic.hide_description()
	var msg = "今日教汝知吾之名！"
	SceneManager.show_confirm_dialog(msg, actorId, 0)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_end", false)
	return

func effect_30240_end():
	if me.get_controlNo() < 0:
		LoadControl.end_script()
		FlowManager.add_flow("unit_action")
	else:
		FlowManager.add_flow("tactic_end")
	return

func get_available_positions(unit:Battle_Unit)->PoolVector2Array:
	var ret = []
	var scene_battle = SceneManager.current_scene()
	var positions = [Vector2(0, 4), Vector2(0, 5), Vector2(0, 6)]
	if unit.get_side() == Vector2.RIGHT:
		for i in positions.size():
			positions[i].x = scene_battle.cell_columns - 1
	for pos in positions:
		# 不可有单位
		if DataManager.get_battle_unit_by_position(pos) != null:
			continue
		# 不可有障碍物
		if scene_battle.get_position_is_roadblock(pos):
			continue
		ret.append(pos)
	return ret
