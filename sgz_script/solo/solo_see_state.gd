extends Resource
const view_model_name = "单挑-玩家-步骤";

#查看信息
func _init() -> void:
	LoadControl.view_model_name = view_model_name;
	FlowManager.bind_import_flow("solo_see_state",self,"solo_see_state");

func _input_key(delta: float):
	var scene_solo:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	match view_model:
		100:#上下调整查看人
			var conEquipInfo = SceneManager.conEquipInfo;
			conEquipInfo.rect_position.y = 289;
			conEquipInfo.show();
			var earray = StaticManager.EQUIPMENT_TYPES
			var equ_type_index = DataManager.get_env_int("装备信息.类型号")
			var equ_type:String = earray[equ_type_index]
			var actor = ActorHelper.actor(SceneManager.actor_info.get_current_actorId())
			conEquipInfo.show_equipinfo(actor.get_equip(equ_type),"info");
			if(Input.is_action_just_pressed("ANALOG_LEFT")):
				equ_type_index -= 1;
				if(equ_type_index < 0):
					equ_type_index = earray.size()-1;
			if(Input.is_action_just_pressed("ANALOG_RIGHT")):
				equ_type_index += 1;
				if(equ_type_index >= earray.size()):
					equ_type_index = 0;
			DataManager.set_env("装备信息.类型号", equ_type_index)
			var current_actorId = DataManager.get_env_int("武将")
			if(Input.is_action_just_pressed("ANALOG_UP")):
				for actorId in DataManager.solo_actors:
					if(actorId == current_actorId):
						continue;
					DataManager.common_variable["武将"]=actorId;
					SceneManager.show_actor_info(actorId);
					return;
			if(Input.is_action_just_pressed("ANALOG_DOWN")):
				for actorId in DataManager.solo_actors:
					if(actorId == current_actorId):
						continue;
					DataManager.common_variable["武将"]=actorId;
					SceneManager.show_actor_info(actorId);
					return;
			if(Global.is_action_pressed_BY()):
				FlowManager.add_flow("solo_player_ready");
#查看武将状态
func solo_see_state():
	LoadControl.set_view_model(100);
	DataManager.set_env("装备信息.类型号", 0)
	var scene_solo = SceneManager.current_scene();
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
	var actorId = DataManager.solo_actor_by_side(side);
	DataManager.common_variable["武将"]=actorId;
	SceneManager.show_actor_info(actorId);
		

