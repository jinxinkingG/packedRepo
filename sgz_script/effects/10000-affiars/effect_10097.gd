extends "effect_10000.gd"

#假道主动技
#【假道】内政，主动技。发动后，金-1000，你所在城池可以进攻一个与盟友相邻的城池。每年限1次。

const EFFECT_ID = 10097
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_GOLD = 1000

func on_trigger_10011()->bool:
	var wf = DataManager.get_current_war_fight()
	if wf.source != ske.skill_name:
		return false
	wf.from_city().add_gold(-COST_GOLD)
	ske.affair_cd(12)
	wf.set_env("额外可撤退城市", [wf.from_city().ID])
	var messages = wf.get_env_array("攻击宣言")
	var msg = "盟友地利，可为我所用\n假道而击{1}\n{2}何以当之！".format([
		"", wf.target_city().get_full_name(),
		clVState.vstate(wf.targetVstateId).get_lord_name(),
	])
	messages.append([msg, actorId, 0])
	wf.set_env("攻击宣言", messages)
	return false

func effect_10097_start():
	var cityId = get_working_city_id()
	var targetCityIds = get_target_city_ids(cityId)
	if targetCityIds.empty():
		var msg = "没有合适的攻击目标\n无法发动【{0}】".format([
			ske.skill_name,
		])
		play_dialog(actorId, msg, 2, 2999)
		return
	var city = clCity.city(cityId)
	if city.get_gold() < COST_GOLD:
		var msg = "城市金不足\n发动【{0}】需金 {1}".format([
			ske.skill_name, COST_GOLD,
		])
		play_dialog(actorId, msg, 3, 2999)
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
	if clCity.city(targetCityId).get_vstate_id() == city.get_vstate_id():
		SceneManager.show_unconfirm_dialog("此为自势力城市")
		return
	if not targetCityId in targets:
		SceneManager.show_unconfirm_dialog("请选择跳攻城市")
		return
	DataManager.set_env("目标", targetCityId)
	goto_step("2")
	return

func on_view_model_3000()->void:
	wait_for_skill_result_confirmation("")
	return

func effect_10097_2():
	var targetCityId = DataManager.get_env_int("目标")
	var msg = "假道攻击{0}\n额外花费金 {1}\n可否？".format([
		clCity.city(targetCityId).get_name(), COST_GOLD,
	])
	play_dialog(actorId, msg, 0, 2001, true)
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_3", "player_ready")
	return

func effect_10097_3():
	var targetCityId = DataManager.get_env_int("目标")
	var wf = DataManager.new_war_fight(get_working_city_id(), targetCityId)
	wf.source = ske.skill_name
	wf.set_env("预扣金", COST_GOLD)
	LoadControl.end_script()
	LoadControl.load_script("affiars/barrack_attack.gd")
	FlowManager.add_flow("attack_choose_actors")
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation()
	return

func get_target_city_ids(cityId:int)->PoolIntArray:
	if cityId < 0:
		return PoolIntArray([])
	var city = clCity.city(cityId)
	var vstateId = city.get_vstate_id()
	var connected = []
	var checked = []
	var targets = []
	for mine in clCity.all_cities([vstateId]):
		for nextCityId in mine.get_connected_city_ids([], [vstateId]):
			connected.append(nextCityId)
			targets.erase(nextCityId)
			var next = clCity.city(nextCityId)
			var nextVstateId = next.get_vstate_id()
			if nextVstateId == -1:
				continue
			if not DataManager.is_alliance(vstateId, nextVstateId):
				continue
			for alliedCity in clCity.all_cities([nextVstateId]):
				for targetCityId in alliedCity.get_connected_city_ids([], [vstateId, nextVstateId]):
					if targetCityId in connected:
						continue
					if targetCityId in checked:
						continue
					checked.append(targetCityId)
					var targetCity = clCity.city(targetCityId)
					if DataManager.is_alliance(targetCity.get_vstate_id(), vstateId):
						continue
					targets.append(targetCityId)
	targets.sort()
	return targets
