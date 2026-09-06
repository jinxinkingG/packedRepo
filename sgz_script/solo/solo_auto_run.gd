extends Resource
const current_step_name = "单挑-当前步骤";
const next_step_name = "单挑-下个步骤";

var player_control;
var ai_control;

#读取当前步骤
func get_current_step()->int:
	return DataManager.get_env_int(current_step_name)

#设置当前步骤
func set_current_step(step:int)->void:
	DataManager.set_env(current_step_name, step)
	return

#读取下个步骤
func get_next_step()->int:
	return DataManager.get_env_int(next_step_name)

#设置下个步骤
func set_next_step(step:int)->void:
	DataManager.set_env(next_step_name, step)
	return

func _init() -> void:
	FlowManager.clear_pre_history.clear()
	LoadControl.end_script()
	FlowManager.clear_bind_method()
	player_control = Global.load_script(DataManager.mod_path+"sgz_script/solo/player_control.gd")
	ai_control = Global.load_script(DataManager.mod_path+"sgz_script/solo/AI_control.gd")
	FlowManager.bind_import_flow("solo_run_start", self)
	FlowManager.bind_import_flow("solo_run_play_trigger", self)
	FlowManager.bind_import_flow("solo_run_play", self)
	FlowManager.bind_import_flow("solo_run_end", self)
	FlowManager.bind_import_flow("solo_init_say", self)
	FlowManager.bind_import_flow("solo_turn_end", self)
	
	return

#单挑开始
func solo_run_start() -> void:
	var bf = DataManager.get_current_battle_fight()
	
	# 攻方总是在左
	var left = bf.get_attacker()
	var right = bf.get_defender()
	
	var sf = DataManager.new_solo_fight(left.actorId, right.actorId)
	if left.get_solo_dex() < right.get_solo_dex():
		sf.fromIdx = 1

	sf.prepare()

	var scene_solo = SceneManager.current_scene()
	scene_solo.init_data()
	set_current_step(-1)
	set_next_step(0)
	return

func _process(delta: float) -> void:
	if DataManager.get_current_scene_id() != 40000:
		return
	var scene = SceneManager.current_scene()
	if scene.bgm:
		SoundManager.play_bgm()

	var sf = DataManager.get_current_solo_fight()
	if not sf.running():
		return
	if FlowManager.has_task():
		return

	#只需要服务器去处理顺序数据
	if AutoLoad.get_local_id() != 1:
		return
	
	if get_next_step() == get_current_step():
		if is_instance_valid(player_control):
			player_control._process(delta)
		if is_instance_valid(ai_control):
			ai_control._process(delta)
		return
	set_current_step(get_next_step())
	
	var current_step = get_current_step()
	match current_step:
		0:#初始叫阵
			FlowManager.add_flow("solo_init_say")
		1:#单方行动回合
			FlowManager.add_flow("solo_run_play_trigger")
		2:#单方行动结束
			FlowManager.add_flow("solo_turn_end")
	return

#结束单挑
func solo_run_end() -> void:
	var sf = DataManager.get_current_solo_fight()
	sf.finish()

	SceneManager.black.show()
	FlowManager.clear_pre_history.clear()
	LoadControl.end_script()
	FlowManager.clear_bind_method()

	FlowManager.add_flow("go_to_scene|res://scene/scene_battle/scene_battle.tscn")
	FlowManager.add_flow("back_from_solo")
	return

#初始叫嚣
func solo_init_say():
	set_current_step(0)
	set_next_step(0)

	var sf = DataManager.get_current_solo_fight()
	for actorId in sf.get_actor_ids():
		if actorId in sf.get_env_int_array("叫阵完成"):
			continue
		sf.currentId = actorId

		var wa = DataManager.get_war_actor(actorId)
		var controlNo = wa.get_controlNo()
		if controlNo < 0:
			var enemy = wa.get_battle_enemy_war_actor()
			controlNo = enemy.get_controlNo()
			if controlNo < 0:
				continue
		FlowManager.set_current_control_playerNo(controlNo)
		FlowManager.add_flow("solo_player_start")
		return
	sf.currentId = sf.leftId
	if sf.fromIdx == 1:
		sf.currentId = sf.rightId
	set_next_step(1)
	return

func solo_run_play_trigger() -> void:
	set_current_step(1)
	set_next_step(1)

	var sf = DataManager.get_current_solo_fight()
	for actorId in sf.get_actor_ids():
		if SkillHelper.auto_trigger_skill(actorId, 40011, "solo_run_play"):
			return
	FlowManager.add_flow("solo_run_play")
	return

func solo_run_play() -> void:
	var sf = DataManager.get_current_solo_fight()
	var wa = sf.current()
	var controlNo = wa.get_controlNo()
	if controlNo >= 0:
		FlowManager.set_current_control_playerNo(controlNo)
		FlowManager.add_flow("solo_player_ready")
	else:
		FlowManager.add_flow("solo_AI_start")
	return

#行动完毕
func solo_turn_end():
	SceneManager.current_scene().update_actor_info()
	set_current_step(2)
	LoadControl.end_script()
	var scene_solo = SceneManager.current_scene()
	scene_solo.init_data()

	var sf = DataManager.get_current_solo_fight()
	sf.end_action()
	set_next_step(1)
	return
