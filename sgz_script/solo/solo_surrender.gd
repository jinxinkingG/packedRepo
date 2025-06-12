extends Resource
const view_model_name = "单挑-玩家-步骤";

#投降
func _init() -> void:
	LoadControl.view_model_name = view_model_name;
	FlowManager.bind_import_flow("solo_surrender",self,"solo_surrender");
	FlowManager.bind_import_flow("solo_surrender_1",self,"solo_surrender_1");
	FlowManager.bind_import_flow("solo_surrender_2",self,"solo_surrender_2");
	FlowManager.bind_import_flow("solo_surrender_3",self,"solo_surrender_3");

func _input_key(delta: float):
	var scene_solo:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	match view_model:
		100:#是否真的投降
			if Input.is_action_just_pressed("ANALOG_LEFT"):
				SceneManager.actor_dialog.move_left()
			if Input.is_action_just_pressed("ANALOG_RIGHT"):
				SceneManager.actor_dialog.move_right()
			if Input.is_action_just_pressed("ANALOG_UP"):
				SceneManager.actor_dialog.move_up()
			if Input.is_action_just_pressed("ANALOG_DOWN"):
				SceneManager.actor_dialog.move_down()
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				match SceneManager.actor_dialog.lsc.cursor_index:
					0:
						FlowManager.add_flow("solo_surrender_1");
					1:
						FlowManager.add_flow("solo_player_ready");
				
			if(Global.is_action_pressed_BY()):
				if(!SceneManager.dialog_msg_complete(false)):
					return;
				FlowManager.add_flow("solo_player_ready");
		101:#确认对话
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				FlowManager.add_flow("solo_surrender_2");
		103:#确认对话
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
				var actorId = DataManager.solo_actor_by_side(side);
				
				var war_actor = DataManager.get_war_actor(actorId);
				var b_war_actor = war_actor.get_battle_enemy_war_actor();
				#下跪投降，算到主动投诚里，大战场保留方块
				if war_actor.actor_surrend_to(b_war_actor.wvId):
					var unit_actor = war_actor.battle_actor_unit();
					unit_actor.is_surrend = true;
					var actor = ActorHelper.actor(actorId)
					actor.set_loyalty(max(10,79-actor.get_loyalty()));#投降忠赋值
				FlowManager.add_flow("solo_run_end")
	return

#投降
func solo_surrender():
	LoadControl.set_view_model(100);
	var scene_solo = SceneManager.current_scene();
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
	var actorId = DataManager.solo_actor_by_side(side);
	var node = scene_solo.get_actor_node(actorId);
	SceneManager.show_yn_dialog("确定要投降吗？",actorId,3);
	SceneManager.actor_dialog.lsc.cursor_index = 1;
	
#投降
func solo_surrender_1():
	LoadControl.set_view_model(101);
	var scene_solo = SceneManager.current_scene();
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
	var actorId = DataManager.solo_actor_by_side(side);
	var node = scene_solo.get_actor_node(actorId);
	SceneManager.show_confirm_dialog("事已至此……\n也……也罢……",actorId,3);
	
#投降
func solo_surrender_2():
	LoadControl.set_view_model(102);
	var scene_solo = SceneManager.current_scene();
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
	var actorId = DataManager.solo_actor_by_side(side);
	var node = scene_solo.get_actor_node(actorId);
	SceneManager.show_unconfirm_dialog(" ");
	scene_solo.bgm = false
	node.action_surrender("solo_surrender_3");

#投降
func solo_surrender_3():
	LoadControl.set_view_model(103);
	var scene_solo = SceneManager.current_scene();
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
	var actorId = DataManager.solo_actor_by_side(side);
	var actor = ActorHelper.actor(actorId)
	var actor_name = actor.get_name()
	var node = scene_solo.get_actor_node(actorId);
	SceneManager.show_confirm_dialog("{0}投降了".format([actor_name]));
