extends "war_base.gd"

#玩家结算界面
func _init() -> void:
	LoadControl.view_model_name = "战争-玩家-步骤"
	FlowManager.bind_import_flow("settle_start", self)
	FlowManager.bind_import_flow("settle_2", self)
	FlowManager.bind_import_flow("settle_resource_report", self)
	FlowManager.bind_import_flow("endless_settle_2", self)
	FlowManager.bind_import_flow("endless_equip", self)
	FlowManager.bind_import_flow("endless_school", self)
	FlowManager.bind_import_flow("war_equip_done", self)
	FlowManager.bind_import_flow("war_school_done", self)
	return

#按键操控
func _input_key(delta: float):
	var wf = DataManager.get_current_war_fight()
	match LoadControl.get_view_model():
		1001:
			Global.wait_for_confirmation("settle_2")
		1010:
			var option = wait_for_view_item()
			if option < 0:
				return
			if Global.is_action_pressed_AX():
				match get_env_int_array("列表值")[option]:
					-1:
						DataManager.auto_save("endless")
						FlowManager.add_flow("war_over_end")
					-2:
						FlowManager.add_flow("endless_equip")
					-3:
						FlowManager.add_flow("endless_school")
				return
			if option != DataManager.get_env_int("值"):
				DataManager.set_env("值", option)
				FlowManager.add_flow("endless_settle_2")
	return

func settle_init():
	#界面展示
	var scene_war = SceneManager.current_scene()
	if not is_instance_valid(scene_war):
		return
	var war_communique = scene_war.war_communique
	war_communique.init_data()
	war_communique.show()
	return

#开始
func settle_start():
	settle_init()
	SoundManager.play_bgm("res://resource/sounds/bgm/War_End.ogg", true, true, true);
	SceneManager.show_confirm_dialog("战斗完成")
	LoadControl.set_view_model(1001)
	return

func settle_2():
	if DataManager.endless_mode:
		DataManager.set_env("值", 0)
		FlowManager.add_flow("endless_settle_2")
		return
	FlowManager.add_flow("war_over_end")
	return

#选择武将
func endless_settle_2():
	var items = []
	var values = []
	for actorId in EndlessGame.player_actors:
		var actorName = ActorHelper.actor(actorId).get_name()
		items.append(actorName)
		values.append(actorId)

	if EndlessGame.pass_no % 5 == 4:
		items.append("装备库#C32,32,212")
		values.append(-2)
		items.append("学问馆#C32,32,212")
		values.append(-3)
	items.append("结束#C212,32,32")
	values.append(-1)

	SceneManager.hide_all_tool()
	DataManager.set_env("列表值", values)
	SceneManager.lsc_menu_top.set_lsc(Vector2(20, 0), Vector2(160, 42))
	SceneManager.lsc_menu_top.lsc.columns = 3
	SceneManager.lsc_menu_top.lsc.items = items
	SceneManager.lsc_menu_top.lsc._set_data()
	SceneManager.lsc_menu_top.lsc.cursor_index = DataManager.get_env_int("值")
	var msg = "无尽成长一览\n[{0}] 第{1}关".format([
		StaticManager.DIFFICULTY_NAMES[DataManager.diffculities],
		EndlessGame.pass_no + 1, 
	]);
	var actorId = values[SceneManager.lsc_menu_top.lsc.cursor_index]
	if actorId >= 0:
		SceneManager.show_actor_info(actorId)
	SceneManager.lsc_menu_top.status.rect_position = Vector2(380, 290)
	SceneManager.lsc_menu_top.status.rect_size = Vector2(180, 80)
	SceneManager.lsc_menu_top.status.bbcode_text = msg
	SceneManager.lsc_menu_top.status.show()
	SceneManager.lsc_menu_top.show()
	LoadControl.set_view_model(1010)
	return

# 无尽模式装备库
func endless_equip():
	LoadControl.load_script("affiars/warehouse_equip.gd")
	FlowManager.add_flow("wh_equip_init")
	LoadControl.set_view_model(1020)
	return

# 无尽模式学问馆
func endless_school():
	LoadControl.set_view_model(1030)
	LoadControl.load_script("affiars/fair_school.gd")
	FlowManager.add_flow("school_start")
	return

func war_equip_done():
	FlowManager.add_flow("endless_settle_2")
	return

func war_school_done():
	FlowManager.add_flow("endless_settle_2")
	return
