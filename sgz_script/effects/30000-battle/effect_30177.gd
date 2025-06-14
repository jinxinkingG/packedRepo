extends "effect_30000.gd"

#侍婢主动技
#【侍婢】小战场，主动技。你的两侧格子为空时，则出现两个兵力120的步兵。（不计入自身兵力）

const EFFECT_ID = 30177
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const MAID_HP = 120
const SIDES = [Vector2.UP, Vector2.DOWN]

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_2", false)
	return

func check_AI_perform()->bool:
	var bf = DataManager.get_current_battle_fight()
	# 第三回合后、身后无人，开始发动
	if bf == null or bf.turns() <= 3:
		return false
	var unit = get_leader_unit(me.actorId)
	if unit == null or unit.disabled:
		return false
	return get_available_positions(unit).size() >= 2

func effect_30177_AI_start():
	goto_step("start")
	return

func effect_30177_start():
	var unit = get_leader_unit(me.actorId)
	var targetPos = get_available_positions(unit)
	if targetPos.empty():
		var msg = "身侧无空位\n无法发动【侍婢】"
		SceneManager.show_confirm_dialog(msg, me.actorId, 3)
		LoadControl.set_view_model(2000)
		return
	ske.battle_cd(99999)
	ske.battle_report()
	var msg = "左右何在！"
	SceneManager.show_confirm_dialog(msg, self.actorId, 0)
	LoadControl.set_view_model(2000)
	return

func effect_30177_2():
	var unit = get_leader_unit(me.actorId)
	for pos in get_available_positions(unit):
		var bu = Battle_Unit.new(actorId)
		bu.unitId = DataManager.battle_units.size()
		bu.direction = unit.direction
		bu._private_hp = MAID_HP
		bu.disabled = false
		bu.init_combat_info("步(侍婢)")
		bu.unit_position = pos
		bu.dic_other_variable["临时"] = 1
		bu.wait_action_times = bu.get_action_times()
		bu.requires_update = true
		DataManager.battle_units.append(bu)
		SceneManager.current_scene().create_or_update_unit(bu)

	if me.get_controlNo() < 0:
		LoadControl.end_script()
		FlowManager.add_flow("unit_action")
	else:
		FlowManager.add_flow("tactic_end")
	return

func get_available_positions(unit:Battle_Unit)->PoolVector2Array:
	var ret = []
	var scene_battle = SceneManager.current_scene()
	for dir in SIDES:
		var pos = unit.unit_position + dir
		# 不可有单位
		if DataManager.get_battle_unit_by_position(pos) != null:
			continue
		# 不可有障碍物
		if scene_battle.get_position_is_roadblock(pos):
			continue
		ret.append(pos)
	return ret
