extends "effect_30000.gd"

#唤援主动技
#【唤援】小战场，主动技。使用后，在我方阵后召唤一个兵力为200，基础伤害倍率+0.25的骑兵（不计入自身兵力，且固定前进状态。）。每个回合限1次。

const EFFECT_ID = 30188
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const XIAOJIANG_HP = 200
const SIDES = [Vector2.UP, Vector2.DOWN]

func on_view_model_2000():
	Global.wait_for_confirmation(FLOW_BASE + "_3")
	return

func on_view_model_2009():
	Global.wait_for_confirmation(FLOW_BASE + "_4")
	return

func check_AI_perform()->bool:
	var bf = DataManager.get_current_battle_fight()
	# 第三回合后、身后无人，开始发动
	if bf == null or bf.turns() <= 3:
		return false
	me = DataManager.get_war_actor(actorId)
	var unit = get_leader_unit(me.actorId)
	if unit == null or unit.disabled:
		return false
	return not get_available_positions(unit).empty()

func effect_30188_AI_start():
	goto_step("start")
	return

func effect_30188_start():
	var unit = get_leader_unit(me.actorId)
	var targets = []
	if unit != null:
		targets = get_available_positions(unit)
	if targets.empty():
		var msg = "阵后无可用位置"
		SceneManager.show_confirm_dialog(msg, me.actorId, 3)
		LoadControl.set_view_model(2009)
		return
	goto_step("2")
	return

func effect_30188_2():
	ske.cost_war_cd(1)
	ske.battle_cd(99999)
	ske.battle_report()
	var msg = "有胆气者，都随我来！"
	SceneManager.show_confirm_dialog(msg, me.actorId, 0)
	LoadControl.set_view_model(2000)
	return

func effect_30188_3():
	var unit = get_leader_unit(actorId)
	var pos = get_available_positions(unit)[0]

	var bu = Battle_Unit.new(actorId)
	bu.unitId = DataManager.battle_units.size()
	bu.direction = unit.direction
	bu._private_hp = XIAOJIANG_HP
	bu.disabled = false
	bu.init_combat_info()
	bu.unit_position = pos
	bu.init_combat_info("骑")
	bu.wait_action_times = bu.get_action_times()
	bu.dic_other_variable["临时"] = 1
	bu.append_combat_val("额外伤害", 0.25)
	bu.dic_combat["暴走"] = 1
	bu.mark_buffed()
	DataManager.battle_units.append(bu)
	SceneManager.current_scene().create_or_update_unit(bu)
	
	var msg = "——\n{0}真猛将也，吾可助之！".format([
		me.get_name()
	])
	SceneManager.show_confirm_dialog(msg, -1, 0, true)
	LoadControl.set_view_model(2009)
	return

func effect_30188_4():
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
