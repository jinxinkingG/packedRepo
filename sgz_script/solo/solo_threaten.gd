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
	var sf = DataManager.get_current_solo_fight()
	var msg = "乳臭未干的小儿\n想打败爷爷我还差100年！"
	SceneManager.show_solo_dialog(msg, sf.currentId, 0)
	LoadControl.set_view_model(100)
	return

#对方回应
func solo_threaten_1():
	var sf = DataManager.get_current_solo_fight()
	var msg = "我要杀了你这兔崽子！"
	SceneManager.show_solo_dialog(msg, sf.target().actorId, 0)
	LoadControl.set_view_model(101)
	return

func solo_threaten_2():
	var sf = DataManager.get_current_solo_fight()
	var target = sf.target()
	if target.get_buff("恫吓")["回合数"] == 0:
		target.set_buff("恫吓", 5, sf.currentId)
	FlowManager.add_flow("solo_turn_end")
	return
