extends "effect_10000.gd"

#立牧主动技
#【立牧】内政，君主主动技。你可以选择一个本方势力刘姓太守，使其成为新势力君主。并与之结盟12个月。每月限1次。

const EFFECT_ID = 10108
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_10108_start():
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var targetCityIds = get_target_city_ids(cityId)
	if targetCityIds.empty():
		var msg = "没有合适的目标\n无法发动【{0}】".format([
			ske.skill_name,
		])
		play_dialog(actorId, msg, 2, 2999)
		return
	SceneManager.hide_all_tool()
	SceneManager.clear_bottom()
	DataManager.twinkle_citys.clear()
	SceneManager.current_scene().cursor.show()
	SceneManager.current_scene().set_city_cursor_position(cityId)
	SceneManager.show_unconfirm_dialog("请选择目标城市")
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000_delta(delta:float)->void:
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var targets = get_target_city_ids(cityId)
	DataManager.twinkle_citys = targets
	var targetCityId = wait_for_choose_city(delta, "player_ready", targets)
	if targetCityId < 0:
		return
	if not targetCityId in targets:
		SceneManager.show_unconfirm_dialog("不可对此城发动")
		return
	DataManager.set_env("目标", targetCityId)
	goto_step("2")
	return

func effect_10108_2():
	var targetCityId = DataManager.get_env_int("目标")
	var targetCity = clCity.city(targetCityId)
	var msg = "发动【{0}】\n令{1}于{2}独立\n可否？".format([
		ske.skill_name, targetCity.get_leader_name(),
		targetCity.get_name(),
	])
	play_dialog(actorId, msg, 0, 2001, true)
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_3", "player_ready")
	return

func effect_10108_3() -> void:
	var cityId = get_working_city_id()
	var targetCityId = DataManager.get_env_int("目标")
	var targetCity = clCity.city(targetCityId)
	var leader = targetCity.get_leader()

	var msg = "{0}威望素著\n况亦汉室宗亲\n何妨独领{1}？".format([
		DataManager.get_actor_honored_title(leader.actorId, actorId),
		targetCity.get_full_name(),
	])
	play_dialog(actorId, msg, 1, 2002)
	DataManager.twinkle_citys = [cityId, targetCityId]
	return

func on_view_model_2002()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_10108_4() -> void:
	var cityId = get_working_city_id()
	var targetCityId = DataManager.get_env_int("目标")
	var targetCity = clCity.city(targetCityId)
	var leader = targetCity.get_leader()

	var msg = "{0}如此美意\n安敢却之？\n当永为唇齿！".format([
		DataManager.get_actor_honored_title(actorId, leader.actorId),
	])
	DataManager.twinkle_citys = [cityId, targetCityId]
	play_dialog(leader.actorId, msg, 1, 2003)
	return

func on_view_model_2003()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_5")
	return

func effect_10108_5() -> void:
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var targetCityId = DataManager.get_env_int("目标")
	var targetCity = clCity.city(targetCityId)
	var leader = targetCity.get_leader()

	ske.affair_cd(1)
	var created = clVState.create_new_vstate(leader.actorId)
	targetCity.change_vstate(created)
	clVState.set_alliance(city.get_vstate_id(), targetCity.get_vstate_id(), 12)
	var msg = "{0}年{1}月\n{2}表{3}为{4}牧\n两家缔结盟约12个月".format([
		DataManager.year, DataManager.month,
		actor.get_name(), leader.get_name(),
		targetCity.get_full_name(),
	])
	DataManager.player_choose_city = targetCityId
	SceneManager.play_affiars_animation("Town_Save", "", true, msg)
	#SceneManager.show_vstate_dialog(msg)
	DataManager.twinkle_citys = [targetCityId]
	LoadControl.set_view_model(2999)
	return

func get_target_city_ids(cityId:int)->PoolIntArray:
	if cityId < 0:
		return PoolIntArray([])
	var targetCityIds = []
	var city = clCity.city(cityId)
	for c in clCity.all_cities([city.get_vstate_id()]):
		if c.ID == cityId:
			continue
		var leader = c.get_leader()
		if leader == null:
			continue
		if leader.get_first_name() == "刘":
			targetCityIds.append(c.ID)
	return targetCityIds
