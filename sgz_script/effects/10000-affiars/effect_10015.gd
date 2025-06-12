extends "effect_10000.gd"

#前非效果
#【前非】内政,主动技。你使用后你的“德”-1（最少为1），每月限一次；若你的德＞=50时，你永久转为阳面，否则你永久转为阴面

const EFFECT_ID = 10015
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000():
	wait_for_skill_result_confirmation("player_ready")
	return

func on_view_model_3000_delta(delta:float):
	var accumulated = DataManager.get_env_float("delta")
	DataManager.set_env("delta", accumulated + delta)
	if accumulated >= 2.0 * Engine.time_scale:
		LoadControl.set_view_model(-1)
		SceneManager.dialog_msg_complete(true)
		goto_step("AI_end")
		return
	wait_for_skill_result_confirmation(FLOW_BASE + "_AI_end")
	return

func check_AI_perform():
	actor = ActorHelper.actor(actorId)
	# 阴面、德 > 1 时，概率发动
	if not actor.is_face_positive() and actor.get_moral() > 1:
		return Global.get_rate_result(60 - actor.get_moral())
	return false

func effect_10015_AI_start():
	ske.affair_cd(1)
	actor.set_moral(max(1, actor.get_moral() - 1))
	check_side()
	SceneManager.show_cityInfo(false)
	var msg = "酒池肉林才是我的归宿...\n（{0}德降为{1}".format([
		actor.get_name(), actor.get_moral()
	])
	SceneManager.show_confirm_dialog(msg, actorId, 1)
	DataManager.set_env("delta", 0)
	LoadControl.set_view_model(3000)
	return

func effect_10015_AI_end():
	SceneManager.hide_all_tool()
	var cityId = DataManager.get_env_int("AI.主动技当前城市")
	var city = clCity.city(cityId)
	var vs = clVState.vstate(city.get_vstate_id())
	var msg = "{0} 军 战略中".format([
		vs.get_dynasty_title_or_lord_name()
	])
	SceneManager.show_vstate_dialog(msg)
	DataManager.twinkle_citys = []
	LoadControl.end_script()
	FlowManager.add_flow("AI_active_skill")
	return

func effect_10015_start():
	ske.affair_cd(1)
	actor.set_moral(max(1, actor.get_moral() - 1))
	check_side()
	SceneManager.show_cityInfo(false)
	var msg = "酒池肉林才是我的归宿...\n（{0}德降为{1}".format([
		actor.get_name(), actor.get_moral()
	])
	SceneManager.show_confirm_dialog(msg, actorId, 1)
	LoadControl.set_view_model(2000)
	return

func on_trigger_10001()->bool:
	check_side()
	return false

func on_trigger_10012()->bool:
	check_side()
	return false

func check_side()->void:
	if actor.get_moral() >= 50:
		actor.set_side("阳")
	else:
		actor.set_side("阴")
	return
