extends "effect_10000.gd"

#安国主动技
#【安国】内政，主动技。以另1个己方城作为目标，仅当目标城和你所在城其中一个是主城时才能发动。你立刻无视连线移动至目标城。每月限2次。

const EFFECT_ID = 10082
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000_delta(delta:float):
	var city = clCity.city(DataManager.player_choose_city)
	var targets = get_target_city_ids(city.ID)
	DataManager.twinkle_citys = targets
	var cityId = wait_for_choose_city(delta, "player_ready", targets)
	if cityId < 0:
		return
	var targetCity = clCity.city(cityId)
	if targetCity.get_vstate_id() != city.get_vstate_id():
		SceneManager.show_unconfirm_dialog("请选择自势力城市")
		return
	if not cityId in targets:
		SceneManager.show_unconfirm_dialog("请选择可发动的目标城市")
		return
	set_env("目标", cityId)
	goto_step("2")
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3", "player_ready")
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation()
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return

func effect_10082_start():
	var city = clCity.city(DataManager.player_choose_city)
	var capital = clCity.get_capital_city(city.get_vstate_id())
	if capital.ID != city.ID:
		set_env("目标", capital.ID)
		goto_step("2")
		return
	var targets = get_target_city_ids(city.ID)
	if targets.empty():
		var msg = "目前并无可发动【{0}】的目标".format([ske.skill_name])
		SceneManager.show_confirm_dialog(msg, actorId, 3)
		LoadControl.set_view_model(2999)
		return

	SceneManager.hide_all_tool()
	SceneManager.clear_bottom()
	DataManager.twinkle_citys = targets
	SceneManager.current_scene().cursor.show()
	SceneManager.current_scene().set_city_cursor_position(DataManager.player_choose_city)
	SceneManager.show_unconfirm_dialog("请选择目标城市")
	LoadControl.set_view_model(2000)
	return

func effect_10082_2():
	DataManager.twinkle_citys.clear()
	var targetCityId = get_env_int("目标")
	var msg = "立即移动到{0}\n可否？".format([
		clCity.city(targetCityId).get_full_name()
	])
	SceneManager.show_yn_dialog(msg, actorId, 2)
	DataManager.twinkle_citys = [targetCityId, DataManager.player_choose_city]
	LoadControl.set_view_model(2001)
	return

func effect_10082_3():
	var targetCityId = get_env_int("目标")
	var targetCity = clCity.city(targetCityId)
	ske.affair_cost_limited_times(2)
	clCity.move_out(actorId)
	clCity.move_to(actorId, targetCityId)
	var msg = "遵命！马上就去"
	SceneManager.play_affiars_animation("Town_Move", "", false, msg, actorId)
	DataManager.twinkle_citys = [targetCityId, DataManager.player_choose_city]
	LoadControl.set_view_model(2002)
	return

func get_target_city_ids(cityId:int)->PoolIntArray:
	var targets = []
	var city = clCity.city(cityId)
	var vs = clVState.vstate(city.get_vstate_id())
	for c in clCity.all_cities([vs.id]):
		targets.append(c.ID)
	targets.erase(clCity.get_capital_city(vs.id).ID)
	return targets
