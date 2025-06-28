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
	FlowManager.clear_pre_history.clear();
	LoadControl.end_script();
	FlowManager.clear_bind_method();
	player_control = Global.load_script(DataManager.mod_path+"sgz_script/solo/player_control.gd")
	ai_control = Global.load_script(DataManager.mod_path+"sgz_script/solo/AI_control.gd")
	FlowManager.bind_import_flow("solo_run_start", self)
	FlowManager.bind_import_flow("solo_run_end", self)
	FlowManager.bind_import_flow("solo_init_say", self)
	FlowManager.bind_import_flow("solo_turn_end", self)
	return

#单挑开始
func solo_run_start():
	DataManager.set_env("单挑.回合数", 0)
	DataManager.solo_actors = PoolIntArray(Array(DataManager.battle_actors).duplicate())
	DataManager.solo_sort = []
	DataManager.solo_sort_no = 0
	DataManager.set_env("单挑.叫嚣完成", [])
	
	var war_left_actor = DataManager.get_war_actor(DataManager.solo_actors[0])
	var war_right_actor = DataManager.get_war_actor(DataManager.solo_actors[1])
	
	#保证左边是玩家
	if war_left_actor.get_controlNo() > war_right_actor.get_controlNo():
		DataManager.solo_actors.invert()
		war_left_actor = DataManager.get_war_actor(DataManager.solo_actors[0])
		war_right_actor = DataManager.get_war_actor(DataManager.solo_actors[1])
	
	if war_left_actor.get_solo_dex() > war_right_actor.get_solo_dex():
		DataManager.solo_sort = ["左","右"]
	else:
		DataManager.solo_sort = ["右","左"]
	
	var scene_solo = SceneManager.current_scene()
	scene_solo.init_data()
	set_next_step(0)
	return

func _process(delta: float) -> void:
	if DataManager.get_current_scene_id() != 40000:
		return
	var scene = SceneManager.current_scene()
	if scene.bgm:
		SoundManager.play_bgm()
	
	if not DataManager.solo_run:
		return;
	if FlowManager.has_task():
		return

	#只需要服务器去处理顺序数据
	if AutoLoad.get_local_id() != 1:
		return
	
	if(get_next_step()==get_current_step()):
		if(is_instance_valid(player_control)):
			player_control._process(delta);
		if(is_instance_valid(ai_control)):
			ai_control._process(delta);
		return;
	set_current_step(get_next_step());
	
	var current_step = get_current_step();
	match current_step:
		0:#初始叫嚣
			FlowManager.add_flow("solo_init_say");
		1:#单方行动回合
			var index = DataManager.solo_sort[DataManager.solo_sort_no];
			var side = DataManager.solo_sort[DataManager.solo_sort_no];
			var actorId = DataManager.solo_actor_by_side(side);
			var war_actor = DataManager.get_war_actor(actorId);
			var controlNo = war_actor.get_controlNo();
			if(controlNo>=0):
				FlowManager.set_current_control_playerNo(controlNo);
				FlowManager.add_flow("solo_player_ready");
			else:
				FlowManager.add_flow("solo_AI_start");
		2:#单方行动结束
			FlowManager.add_flow("solo_turn_end");

#结束单挑
func solo_run_end():
	SceneManager.black.show();
	FlowManager.clear_pre_history.clear();
	LoadControl.end_script();
	FlowManager.clear_bind_method();
	DataManager.solo_actors = [];
	DataManager.solo_sort = [];
	DataManager.solo_sort_no = 0;
	#清空单挑BUFF
	for actorId in DataManager.battle_actors:
		var wa = DataManager.get_war_actor(actorId)
		wa.clear_buff_by_where("单挑")
	DataManager.unset_env("白兵.攻击目标")
	DataManager.unset_env("白兵.攻击来源")

	DataManager.solo_run = false
	FlowManager.add_flow("go_to_scene|res://scene/scene_battle/scene_battle.tscn")
	FlowManager.add_flow("back_from_solo")
	return

#初始叫嚣
func solo_init_say():
	set_current_step(0);
	set_next_step(0);
	var complete_array = Array(DataManager.common_variable["单挑.叫嚣完成"]);
	for index in DataManager.solo_sort.size():
		var side = DataManager.solo_sort[index];
		if(complete_array.has(side)):
			continue;
		DataManager.solo_sort_no = index;
		
		var actorId = DataManager.solo_actor_by_side(side);
		var war_actor = DataManager.get_war_actor(actorId);
		var controlNo = war_actor.get_controlNo();
		if(controlNo<0):
			var war_enemy_actor = war_actor.get_battle_enemy_war_actor();
			controlNo = war_enemy_actor.get_controlNo();
			if(controlNo<0):
				continue;
		FlowManager.set_current_control_playerNo(controlNo);
		FlowManager.add_flow("solo_player_start");
		return;
	DataManager.solo_sort_no = 0;
	set_next_step(1);

#行动完毕
func solo_turn_end():
	SceneManager.current_scene().update_actor_info()
	set_current_step(2);
	LoadControl.end_script();
	var scene_solo = SceneManager.current_scene();
	scene_solo.init_data();
	
	if(DataManager.solo_sort_no<DataManager.solo_sort.size()):
		var side = DataManager.solo_sort[DataManager.solo_sort_no];
		var actorId = DataManager.solo_actor_by_side(side);
		var wa = DataManager.get_war_actor(actorId);
		wa.decrease_buff_by_where("单挑");
	
	DataManager.solo_sort_no+=1;
	if(DataManager.solo_sort_no>=DataManager.solo_sort.size()):
		if(!DataManager.common_variable.has("单挑.回合数")):
			DataManager.common_variable["单挑.回合数"]=0;
		DataManager.common_variable["单挑.回合数"]+=1;
		DataManager.solo_sort_no = 0;
		var war_left_actor = DataManager.get_war_actor(DataManager.solo_actors[0]);
		var war_right_actor = DataManager.get_war_actor(DataManager.solo_actors[1]);
		var left_DEX = war_left_actor.get_solo_dex();
		var right_DEX = war_right_actor.get_solo_dex();
		if(left_DEX>right_DEX):
			DataManager.solo_sort = ["左","右"];
		else:
			DataManager.solo_sort = ["右","左"];
	set_next_step(1);
