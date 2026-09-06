extends Resource

const VIEW_MODEL_NAME = "单挑-玩家-步骤"

func get_view_model() -> int:
	return DataManager.get_env_int(VIEW_MODEL_NAME)

func set_view_model(vm:int) -> void:
	DataManager.set_env(VIEW_MODEL_NAME, vm)
	return

#投降
func _init() -> void:
	FlowManager.bind_import_flow("solo_surrender", self)
	FlowManager.bind_import_flow("solo_surrender_1", self)
	FlowManager.bind_import_flow("solo_surrender_2", self)
	FlowManager.bind_import_flow("solo_surrender_3", self)
	FlowManager.bind_import_flow("solo_surrender_4", self)
	return

func _input_key(delta: float):
	var scene:Control = SceneManager.current_scene()
	var bottom = SceneManager.lsc_menu
	match get_view_model():
		100:#是否真的投降
			Global.wait_for_yesno("solo_surrender_1", "solo_player_ready", VIEW_MODEL_NAME)
		101:#确认对话
			Global.wait_for_confirmation("solo_surrender_2", VIEW_MODEL_NAME)
		103:#确认对话
			Global.wait_for_confirmation("solo_surrender_4", VIEW_MODEL_NAME)
	return

# 投降询问
func solo_surrender() -> void:
	var sf = DataManager.get_current_solo_fight()
	SceneManager.show_yn_dialog("确定要投降吗？", sf.currentId, 3)
	SceneManager.actor_dialog.lsc.cursor_index = 1
	set_view_model(100)
	return

# 投降确认
func solo_surrender_1() -> void:
	var sf = DataManager.get_current_solo_fight()
	SceneManager.show_confirm_dialog("事已至此……\n也……也罢……", sf.currentId, 3)
	set_view_model(101)
	return

# 投降动画
func solo_surrender_2() -> void:
	var sf = DataManager.get_current_solo_fight()
	var scene = SceneManager.current_scene()
	var node = scene.get_actor_node(sf.currentId)
	SceneManager.show_unconfirm_dialog(" ")
	scene.bgm = false
	node.action_surrender("solo_surrender_3")
	return

# 投降汇报
func solo_surrender_3() -> void:
	var sf = DataManager.get_current_solo_fight()
	var scene = SceneManager.current_scene()
	var node = scene.get_actor_node(sf.currentId)
	SceneManager.show_confirm_dialog("{0}投降了".format([sf.current().get_name()]));
	set_view_model(103)
	return

# 投降结果
func solo_surrender_4() -> void:
	var sf = DataManager.get_current_solo_fight()
	var wa = sf.current()
	var opponent = sf.opponent(wa.actorId)
	# 下跪投降，算到主动投诚里，大战场保留方块
	if wa.actor_surrend_to(opponent.wvId):
		var bu = wa.battle_actor_unit()
		bu.is_surrend = true
	FlowManager.add_flow("solo_run_end")
	return
