extends "effect_10000.gd"

# 探阵主动技
#【探阵】内政，主动技。无须消耗命令书，你单独出征。每月限1次。

const EFFECT_ID = 10117
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_10117_start() -> void:
	SceneManager.hide_all_tool()
	SceneManager.clear_bottom()
	DataManager.twinkle_citys.clear()
	SceneManager.current_scene().cursor.show()
	SceneManager.current_scene().set_city_cursor_position(DataManager.player_choose_city)
	SceneManager.show_unconfirm_dialog("请选择目标城市")
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000_delta(delta:float) -> void:
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
		SceneManager.show_unconfirm_dialog("请选择目标城市")
		return
	DataManager.set_env("目标", cityId)
	goto_step("selected")
	return

func effect_10117_selected() -> void:
	var targetCityId = DataManager.get_env_int("目标")
	var msg = "孤军出阵\n一探{0}虚实\n可否？".format([
		clCity.city(targetCityId).get_name()
	])
	play_dialog(actorId, msg, 0, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed", "player_ready")
	return

func effect_10117_confirmed() -> void:
	var targetCityId = DataManager.get_env_int("目标")
	var wf = DataManager.new_war_fight(DataManager.player_choose_city, targetCityId)
	wf.source = ske.skill_name
	DataManager.set_env("派遣武将", [actorId])
	LoadControl.end_script()
	LoadControl.load_script("affiars/barrack_attack.gd")
	FlowManager.add_flow("attack_with_goods")
	return

func get_target_city_ids(cityId:int)->PoolIntArray:
	var city = clCity.city(cityId)
	var targets = []
	for id in city.get_connected_city_ids([], [city.get_vstate_id()]):
		if id in targets:
			continue
		var target = clCity.city(id)
		if 0 < clVState.get_alliance_month(target.get_vstate_id(), city.get_vstate_id()):
			continue
		targets.append(id)
	targets.sort()
	return targets

func on_trigger_10022() -> bool:
	var wf = DataManager.get_current_war_fight()
	if wf.source != ske.skill_name:
		return false
	wf.set_env("不消耗命令书", 1)
	var messages = wf.get_env_array("攻击宣言")
	messages.append(["愿为大军前驱！", actorId, 0])
	wf.set_env("攻击宣言", messages)
	wf.set_env("跳过默认攻击宣言", 1)
	ske.affair_cd(1)
	return false
