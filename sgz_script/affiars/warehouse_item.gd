extends "affairs_base.gd"

func _init()->void :
	LoadControl.view_model_name = "内政-玩家-步骤";
	FlowManager.bind_import_flow("wh_item_init", self, "wh_item_init");
	return

func _input_key(delta:float):
	var scene_affiars:Control = SceneManager.current_scene();
	var top = SceneManager.lsc_menu_top;
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	
