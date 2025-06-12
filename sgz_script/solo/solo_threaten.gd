extends Resource
const view_model_name = "单挑-玩家-步骤";

#恫吓
func _init() -> void:
	LoadControl.view_model_name = view_model_name;
	FlowManager.bind_import_flow("solo_threaten", self)
	FlowManager.bind_import_flow("solo_threaten_1", self)
	FlowManager.bind_import_flow("solo_threaten_2", self)
	return

func _input_key(delta: float):
	var scene_solo:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	match view_model:
		100:#确认己方说话
			Global.wait_for_confirmation("solo_threaten_1")
		101:#确认对方回话
			Global.wait_for_confirmation("solo_threaten_2")
	return

#恫吓文字
func solo_threaten():
	LoadControl.set_view_model(100);
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
	var actorId = DataManager.solo_actor_by_side(side);
	var text = "乳臭未干的小儿\n想打败爷爷我还差100年！";
	SceneManager.show_solo_dialog(text,actorId,0);

#对方回应
func solo_threaten_1():
	LoadControl.set_view_model(101);
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
	var actorId = DataManager.solo_actor_by_side(side);
	var war_actor = DataManager.get_war_actor(actorId);
	var war_enrmy = war_actor.get_battle_enemy_war_actor();
	var text = "我要杀了你这兔崽子！";
	SceneManager.show_solo_dialog(text,war_enrmy.actorId,0);

func solo_threaten_2():
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
	var actorId = DataManager.solo_actor_by_side(side)
	var wa = DataManager.get_war_actor(actorId)
	var enemy = wa.get_battle_enemy_war_actor()
	if enemy.get_buff("恫吓")["回合数"] == 0:
		enemy.set_buff("恫吓", 5, actorId)
	FlowManager.add_flow("solo_turn_end")
	return
