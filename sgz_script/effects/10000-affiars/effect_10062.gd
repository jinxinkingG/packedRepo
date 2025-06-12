extends "effect_10000.gd"

#凿险主动技
#【凿险】内政，主动技。你可选择一个与你所在城隔着一个城的非己方城为目标，对之进行出征指令。以此法出征的己方将领兵力下降 10%。每月限一次。

const EFFECT_ID = 10062
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_10062_start():
	SceneManager.hide_all_tool()
	SceneManager.clear_bottom()
	DataManager.twinkle_citys.clear()
	SceneManager.current_scene().cursor.show()
	SceneManager.current_scene().set_city_cursor_position(DataManager.player_choose_city)
	SceneManager.show_unconfirm_dialog("请选择目标城市")
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000_delta(delta:float)->void:
	var city = clCity.city(DataManager.player_choose_city)
	var targets = get_target_city_ids(city.ID)
	DataManager.twinkle_citys = targets
	var cityId = wait_for_choose_city(delta, "player_ready", targets)
	if cityId < 0:
		return
	if clCity.city(cityId).get_vstate_id() == city.get_vstate_id():
		SceneManager.show_unconfirm_dialog("此为自势力城市")
		return
	if not cityId in targets:
		SceneManager.show_unconfirm_dialog("请选择跳攻城市")
		return
	DataManager.set_env("目标", cityId)
	goto_step("2")
	return

func effect_10062_2():
	var targetCityId = DataManager.get_env_int("目标")
	var msg = "凿险攻击{0}\n出阵部队兵力将损失 10%\n可否？".format([
		clCity.city(targetCityId).get_name()
	])
	play_dialog(actorId, msg, 0, 2001)
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_3", "player_ready")
	return

func effect_10062_3():
	var targetCityId = DataManager.get_env_int("目标")
	var wf = DataManager.new_war_fight(DataManager.player_choose_city, targetCityId)
	wf.source = ske.skill_name
	LoadControl.end_script()
	LoadControl.load_script("affiars/barrack_attack.gd")
	FlowManager.add_flow("attack_choose_actors")
	return

func on_trigger_10011()->bool:
	var wf = DataManager.get_current_war_fight()
	if wf.source != ske.skill_name:
		return false
	ske.affair_cd(1)
	for actorId in wf.sendActors:
		var actor = ActorHelper.actor(actorId)
		actor.set_soldiers(actor.get_soldiers() * 0.9)
	var messages = wf.get_env_array("攻击宣言")
	messages.append(["岂有不行险而得天下者？\n全军出击！", actorId, 0])
	wf.set_env("攻击宣言", messages)
	return false

func get_target_city_ids(cityId:int)->PoolIntArray:
	var city = clCity.city(cityId)
	var connected = city.get_connected_city_ids()
	var targets = []
	for id in connected:
		var next = clCity.city(id).get_connected_city_ids([], [city.get_vstate_id()])
		for targetId in next:
			if targetId == cityId:
				continue
			if targetId in connected:
				continue
			if targetId in targets:
				continue
			if 0 < clVState.get_alliance_month(clCity.city(targetId).get_vstate_id(), city.get_vstate_id()):
				continue
			targets.append(targetId)
	targets.sort()
	return targets
