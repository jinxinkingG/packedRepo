extends "war_base.gd"

#待机
func _init() -> void:
	LoadControl.view_model_name = "战争-玩家-步骤"
	FlowManager.bind_signal_method("sleep_start", self)
	return

#按键操控
func _input_key(delta: float):
	match LoadControl.get_view_model():
		131:#待机
			wait_for_confirmation("player_end", "player_ready")
	return

#待机
func sleep_start():
	var msg = "既然如此，全军待机\n观看敌方行动"
	if DataManager.is_extra_war_round():
		msg = "结束额外回合\n观看敌方行动"
	SceneManager.show_confirm_dialog(msg, DataManager.player_choose_actor)
	LoadControl.set_view_model(131)
	return
