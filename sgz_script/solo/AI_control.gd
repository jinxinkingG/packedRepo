extends Resource

const view_model_name = "单挑-AI-步骤";
#0-牵制，1-逃跑，2-攻击，3-投降，4-说服，5-恫吓，6-舍命
var action_list =[
	#0<敌人体≤31
	[0, 0, 0, 2, 2, 2, 2, 2],#0<自身体≤31
	[0, 0, 0, 4, 4, 2, 2, 2],#31<自身体≤61
	[0, 0, 5, 5, 4, 4, 2, 2],#自身体>61
	#31<敌人体≤61
	[0, 2, 2, 4, 5, 2, 2, 2],#0<自身体≤31
	[0, 0, 0, 0, 2, 2, 2, 2],#31<自身体≤61
	[0, 0, 0, 5, 4, 2, 2, 2],#自身体>61
	#敌人体>61
	[0, 1, 1, 4, 4, 6, 6, 6],#0<自身体≤31
	[0, 1, 2, 2, 2, 2, 5, 4],#31<自身体≤61
	[0, 0, 4, 4, 2, 2, 2, 2]#自身体>61
];

func get_view_model():
	if(!DataManager.common_variable.has(view_model_name)):
		return -1;
	return int(DataManager.common_variable[view_model_name]);

func set_view_model(view_model:int):
	DataManager.common_variable[view_model_name] = int(view_model);


func _init() -> void:
	FlowManager.bind_import_flow("solo_AI_start",self,"solo_AI_start");

func _process(delta: float) -> void:
	if(AutoLoad.playerNo != FlowManager.controlNo):
		return;
	_input_key(delta);

func _input_key(delta: float):
	var scene_solo:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = get_view_model();
	match view_model:
		0:
			pass

#AI回合开始
func solo_AI_start():
	set_view_model(0);
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
	var actorId = DataManager.solo_actor_by_side(side);
	#AI判读步骤
	var action_order = 0;
	var actor = ActorHelper.actor(actorId);
	var wa = DataManager.get_war_actor(actorId);
	var enemy_wa:War_Actor = wa.get_battle_enemy_war_actor();
	var enemy_actor = ActorHelper.actor(enemy_wa.actorId);
	var a = 0;
	var actorHP = actor.get_hp()
	var enemyHP = enemy_actor.get_hp()
	if enemyHP > 31:
		a += 3;
	if enemyHP > 61:
		a += 3;
	if actorHP > 31:
		a += 1;
	if actorHP > 61:
		a += 1;
	while (true):
		action_order = action_list[a][Global.get_random(0,7)];
		if action_order == 3 and actor.get_loyalty() == 100:
			continue;
		break;
	var controlNo = enemy_wa.get_controlNo();
	if(controlNo<0):
		controlNo = 0;
	FlowManager.set_current_control_playerNo(controlNo);
	DataManager.common_variable["单挑.行为"] = action_order;
	match action_order:
		0:#牵制攻击
			FlowManager.add_flow("load_script|solo/solo_light_attack.gd");
			FlowManager.add_flow("solo_light_attack");
		1:#撤退
			FlowManager.add_flow("load_script|solo/solo_retreat.gd");
			FlowManager.add_flow("solo_retreat");
		2:#攻击
			FlowManager.add_flow("load_script|solo/solo_attack.gd");
			FlowManager.add_flow("solo_attack");
		3:#投降
			FlowManager.add_flow("load_script|solo/solo_surrender.gd");
			FlowManager.add_flow("solo_surrender_1");
		4:#说服
			FlowManager.add_flow("load_script|solo/solo_persuade.gd");
			FlowManager.add_flow("solo_persuade");
		5:#恫吓
			FlowManager.add_flow("load_script|solo/solo_threaten.gd");
			FlowManager.add_flow("solo_threaten");
		6:#舍命一击
			FlowManager.add_flow("load_script|solo/solo_crazy_attack.gd");
			FlowManager.add_flow("solo_crazy_attack");
