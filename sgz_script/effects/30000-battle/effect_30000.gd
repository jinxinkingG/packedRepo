extends "res://script/effects_base.gd"

const VIEW_MODEL = "白兵.技能.步骤"

# 特殊的单位类型数组，用于加强全体士兵
const UNIT_TYPE_SOLDIERS = ["SOLDIERS"]

const KEY_ACTION_UNIT = "白兵.行动单位"

#返回是否能触发(默认true)，子类需要用这个的时候应重写该方法
func check_trigger_correct() -> bool:
	if me == null:
		return false
	var method = "on_trigger_{0}".format([ske.trigger_Id])
	if has_method(method):
		return call(method)
	return false

#func get_view_model()->int:
#	return DataManager.get_env_int(VIEW_MODEL)

#func set_view_model(vm:int)->void:
#	DataManager.set_env(VIEW_MODEL, vm)
#	return

# 初始化局部变量，应在 _init() 中调用
func init_vars():
	ske = SkillHelper.read_skill_effectinfo()
	if ske != null:
		actorId = ske.skill_actorId
		triggerId = ske.trigger_Id
		actor = ActorHelper.actor(actorId)
		me = ske.get_war_actor()
		if me != null:
			enemy = me.get_battle_enemy_war_actor()
			if enemy != null:
				enemyActor = ActorHelper.actor(enemy.actorId)
	wf = DataManager.get_current_war_fight()
	bf = DataManager.get_current_battle_fight()
	return

#获取当前行动的单位
func get_action_unit()->Battle_Unit:
	if not check_env([KEY_ACTION_UNIT]):
		return null
	var unitIdx = int(get_env(KEY_ACTION_UNIT))
	if unitIdx < 0  or unitIdx >= DataManager.battle_units.size():
		return null
	return DataManager.battle_units[unitIdx]

# 信息发动后的结果确认
func wait_for_skill_result_confirmation(nextFlow:String="", endScript:bool=true):
	if not Global.wait_for_confirmation(nextFlow):
		return
	if endScript:
		skill_end_clear()
	return

# 根据环境变量获取当前战术名
func get_tactic_name()->String:
	if not check_env([KEY_VALUE]):
		return ""
	return str(get_env(KEY_VALUE))

# 根据环境变量判断当前战术结果
# 成功 = 1，失败 = 0，未知 = -1
# 环境异常视为未知，应准备判断返回值是 0 还是 1
func get_tactic_result()->int:
	if not check_env([KEY_RESULTS]):
		return -1
	var results = int(get_env(KEY_RESULTS))
	if results:
		return 1
	return 0

# 获取主将单位
func get_leader_unit(actorId:int, includeDisabled:bool=false)->Battle_Unit:
	for bu in DataManager.battle_units:
		if bu == null:
			continue
		if bu.disabled and not includeDisabled:
			continue
		if bu.leaderId == actorId and bu.get_unit_type() == "将":
			return bu
	return null

func unit_jump_forward(bu:Battle_Unit, steps:int)->void:
	var rng = range(-steps, 0)
	if bu.get_side() == Vector2.LEFT:
		rng = range(steps, 0, -1)
	for x in rng:
		var pos = bu.unit_position + Vector2(x, 0)
		if bu.can_move_to_position(pos):
			bu.unit_position = pos
			break
	bu.requires_update = true
	return

func get_battle_unit(unitId:int)->Battle_Unit:
	if unitId < 0 or unitId >= DataManager.battle_units.size():
		return null
	return DataManager.battle_units[unitId]

# 确认是否
# 等待是否确认，决定去哪个分支
func wait_for_yesno(flowForYes:String, flowForNo:String="")->void:
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		SceneManager.actor_dialog.move_left()
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		SceneManager.actor_dialog.move_right()
	if Global.is_action_pressed_BY():
		if not SceneManager.dialog_msg_complete(false):
			return
		LoadControl.set_view_model(-1)
		if flowForNo != "":
			FlowManager.add_flow(flowForNo)
			return
		LoadControl.end_script()
		return
	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	LoadControl.set_view_model(-1)
	match SceneManager.actor_dialog.lsc.cursor_index:
		0:
			FlowManager.add_flow(flowForYes)
		1:
			if flowForNo != "":
				FlowManager.add_flow(flowForNo)
				return
			LoadControl.end_script()
	return

# 小战场插入对话
func append_free_dialog(wa:War_Actor, msg:String, mood:int, attachTo:War_Actor=null)->War_Character.DialogInfo:
	if attachTo == null:
		attachTo = wa
	var d = War_Character.DialogInfo.new()
	if wa == null:
		d.actorId = -1
	else:
		d.actorId = wa.actorId
	d.text = msg
	d.mood = mood
	d.sceneId = 30000
	attachTo.add_dialog_info(d)
	return d

# 选择在目标位置中选择，支持主动技
func wait_for_select_position(nextFlow:String, backFlow:String="unit_action"):
	if Global.is_action_pressed_BY():
		if not SceneManager.dialog_msg_complete():
			return
		FlowManager.add_flow(backFlow)
		return

	var sceneBattle = SceneManager.current_scene()
	var current = sceneBattle.cursor_position
	var marked = sceneBattle.marked_positions
	if current == null or not current in marked:
		current = marked[0]
		sceneBattle.move_cursor_to(current)
	var idx = marked.find(current)
	if Input.is_action_just_pressed("ANALOG_UP"):
		idx = ActorHelper.find_next_war_position(marked, idx, Vector2.UP)
	if Input.is_action_just_pressed("ANALOG_DOWN"):
		idx = ActorHelper.find_next_war_position(marked, idx, Vector2.DOWN)
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		idx = ActorHelper.find_next_war_position(marked, idx, Vector2.LEFT)
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		idx = ActorHelper.find_next_war_position(marked, idx, Vector2.RIGHT)
	current = marked[idx]
	sceneBattle.move_cursor_to(current)

	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	LoadControl.set_view_model(-1)
	FlowManager.add_flow(nextFlow)
	return

# 默认的 2990 view model，确认对话并结束被动技
func on_view_model_2990()->void:
	wait_for_skill_result_confirmation("")
	return

# 默认的 2999 view model，确认对话并结束主动技
func on_view_model_2999()->void:
	wait_for_skill_result_confirmation()
	return

func tactic_end(nextFlow:String="unit_action") -> void:
	var scene_battle = SceneManager.current_scene()
	scene_battle.battle_tactic.hide()
	scene_battle.battle_state.hide()
	SceneManager.actor_dialog.hide()
	scene_battle.main_bottom.update_data()
	scene_battle.main_bottom.show()
	LoadControl.end_script()
	FlowManager.add_flow(nextFlow)
	return
