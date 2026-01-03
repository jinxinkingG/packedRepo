extends "effect_10000.gd"

# 迁民主动技
#【迁民】内政，主动技。你可选择一个与本城相邻的己方城池，消耗1枚命令书发动，均分这两座城的人口数量。每月限1次。

const EFFECT_ID = 10134
const FLOW_BASE = "effect_" + str(EFFECT_ID)


func effect_10134_start() -> void:
	var first = clCity.city(DataManager.player_choose_city)
	var choices = first.get_connected_city_ids([first.get_vstate_id()])
	if choices.empty():
		var msg = "没有相邻城池\n不可发动【{0}】".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return

	SceneManager.hide_all_tool()
	SceneManager.clear_bottom()
	SceneManager.current_scene().cursor.show()
	SceneManager.current_scene().set_city_cursor_position(choices[0])
	var msg = "{0}现有人口{1}\n请选择目标城市".format([
		first.get_full_name(), first.get_pop(),
	])
	SceneManager.show_unconfirm_dialog(msg)
	LoadControl.set_view_model(2000)
	DataManager.twinkle_citys = choices
	return

func on_view_model_2000_delta(delta:float):
	var first = clCity.city(DataManager.player_choose_city)
	var pointedCityId = SceneManager.current_scene().get_curosr_point_city()
	if pointedCityId < 0:
		SceneManager.show_cityInfo(false)
	else:
		var msg = "{0}现有人口{1}\n请选择目标城市".format([
			first.get_full_name(), first.get_pop(),
		])
		SceneManager.actor_dialog.update_message(msg)
		SceneManager.show_cityInfo(true, pointedCityId, 1)
	var choices = first.get_connected_city_ids([first.get_vstate_id()])
	var cityId = wait_for_choose_city(delta, "player_ready", choices)
	if cityId < 0:
		return
	if clCity.city(cityId).get_vstate_id() != first.get_vstate_id():
		SceneManager.show_unconfirm_dialog("此非我方城池")
		return
	if not cityId in choices:
		SceneManager.show_unconfirm_dialog("此非相邻城池")
		return
	DataManager.set_env("目标", cityId)
	goto_step("selected")
	return

func effect_10134_selected() -> void:
	var first = clCity.city(DataManager.player_choose_city)
	var targetCityId = DataManager.get_env_int("目标")
	var targetCity = clCity.city(targetCityId)

	var popA = int(first.get_pop() / 100)
	var popB = int(targetCity.get_pop() / 100)
	var diff = int(popA - popB) / 2 * 100
	if diff == 0:
		var msg = "两城人口已均\n不必劳民"
		play_dialog(actorId, msg, 2, 2999)
		return

	var data = [first.get_name(), targetCity.get_name(), diff]
	var msg = "{0}繁荣，{1}凋敝\n均分户口，军民两利\n（从{0}迁出人口 {2}"
	if diff < 0:
		msg = "{0}繁荣，{1}凋敝\n均分户口，军民两利\n（向{1}迁入人口 {2}"
		data = [targetCity.get_name(), first.get_name(), -diff]
	first.add_city_property("人口", -diff)
	targetCity.add_city_property("人口", diff)
	ske.affair_cd(1)
	DataManager.orderbook -= 1
	msg = msg.format(data)
	play_dialog(actorId, msg, 1, 2999)
	SceneManager.current_scene().set_city_cursor_position(first.ID)
	SceneManager.show_cityInfo(true, first.ID, 1)
	return
