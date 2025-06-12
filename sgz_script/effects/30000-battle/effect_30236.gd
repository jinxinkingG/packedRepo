extends "effect_30000.gd"

#亲士主动技
#【亲士】大战场&小战场，主动技。①你的[士]不低于300时可发动：你的前、左、右，分别出现一队兵力100的骑兵、步兵、弓兵。每出现1队士兵：你的[士]-100，士气+2。白刃战限1次。②战争初始，你[士]+300，上限3000。

const EFFECT_ID = 30236
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const UNIT_HP = 100
const SETTINGS = [
	[Vector2.RIGHT, "骑"],
	[Vector2.UP, "步"],
	[Vector2.DOWN, "弓"],
]

const FLAG_ID = 10068
const FLAG_NAME = "士"

func check_AI_perform()->bool:
	var bf = DataManager.get_current_battle_fight()
	# 第三回合后、身后无人，开始发动
	if bf == null or bf.turns() <= 3:
		return false
	me = DataManager.get_war_actor(actorId)
	var unit = me.battle_actor_unit()
	if unit == null or unit.disabled:
		return false
	var flagSceneId = FLAG_ID - FLAG_ID % 10000
	var flags = SkillHelper.get_skill_flags_number(flagSceneId, FLAG_ID, actorId, FLAG_NAME)
	if flags < UNIT_HP:
		return false
	return not get_available_settings(unit).empty()

func effect_30236_AI_start():
	goto_step("start")
	return

func effect_30236_start():
	var flagSceneId = FLAG_ID - FLAG_ID % 10000
	var flags = SkillHelper.get_skill_flags_number(flagSceneId, FLAG_ID, actorId, FLAG_NAME)
	if flags < UNIT_HP:
		var msg = "[{0}]不足，无法发动【{1}】".format([FLAG_NAME, ske.skill_name])
		SceneManager.show_confirm_dialog(msg, actorId, 3)
		LoadControl.set_view_model(2000)
		return
	var unit = me.battle_actor_unit()
	var targets = []
	if unit != null:
		targets = get_available_settings(unit)
	if targets.empty():
		var msg = "无可用位置"
		SceneManager.show_confirm_dialog(msg, actorId, 3)
		LoadControl.set_view_model(2000)
		return
	goto_step("2")
	return

func effect_30236_2():
	var flagSceneId = FLAG_ID - FLAG_ID % 10000
	var flags = SkillHelper.get_skill_flags_number(flagSceneId, FLAG_ID, actorId, FLAG_NAME)
	var unit = get_leader_unit(me.actorId)
	var settings = get_available_settings(unit)

	ske.battle_cd(99999)
	var added = 0
	for i in min(3, int(flags / UNIT_HP)):
		if settings.empty():
			break
		var setting = settings.pop_front()
		ske.cost_skill_flags(flagSceneId, FLAG_ID, FLAG_NAME, UNIT_HP)
		added += 1
		var bu = Battle_Unit.new()
		bu.unitId = DataManager.battle_units.size()
		bu.leaderId = actorId
		bu.direction = unit.direction
		bu._private_hp = UNIT_HP
		bu.disabled = false
		bu.unit_position = unit.unit_position + setting[0]
		bu.init_combat_info(setting[1])
		bu.wait_action_times = bu.get_action_times()
		bu.dic_other_variable["临时"] = 1
		DataManager.battle_units.append(bu)
		SceneManager.current_scene().create_or_update_unit(bu)

	var morale = added * 2
	ske.battle_change_morale(morale, me)

	ske.battle_report()

	SceneManager.current_scene().battle_tactic.hide_description()
	var msg = "家国一体，亲卫何在！"
	SceneManager.show_confirm_dialog(msg, actorId, 0)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_end", false)
	return

func effect_30236_end():
	if me.get_controlNo() < 0:
		LoadControl.end_script()
		FlowManager.add_flow("unit_action")
	else:
		FlowManager.add_flow("tactic_end")
	return

func get_available_settings(unit:Battle_Unit)->Array:
	var ret = []
	var scene_battle = SceneManager.current_scene()
	var settings = SETTINGS.duplicate(true)
	if unit.get_side() == Vector2.RIGHT:
		for i in settings.size():
			settings[i][0] = Vector2.ZERO - settings[i][0]
	for setting in settings:
		var pos = unit.unit_position + setting[0]
		# 不可有单位
		if DataManager.get_battle_unit_by_position(pos) != null:
			continue
		# 不可有障碍物
		if scene_battle.get_position_is_roadblock(pos):
			continue
		ret.append(setting)
	return ret
