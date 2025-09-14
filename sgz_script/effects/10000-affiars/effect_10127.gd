extends "effect_10000.gd"

# 质盟主动技
#【质盟】内政，主动技。你非君主，可指定1个其他势力发动。你移动至该势力主城并转移阵营，两势力结盟12月，之后你永久获得<戈室>。游戏中限1次。


const EFFECT_ID = 10127
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const TARGET_SKILL = "戈室"

func effect_10127_start():
	var city = clCity.city(DataManager.player_choose_city)
	var candidates = get_target_city_ids(city)
	if candidates.empty():
		var msg = "没有可以发动的目标势力"
		play_dialog(actorId, msg, 3, 2999)
		return
	SceneManager.hide_all_tool()
	SceneManager.clear_bottom()
	DataManager.twinkle_citys.clear()
	SceneManager.current_scene().cursor.show()
	SceneManager.current_scene().set_city_cursor_position(DataManager.player_choose_city)
	SceneManager.show_unconfirm_dialog("请选择目标势力")
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000_delta(delta:float)->void:
	var city = clCity.city(DataManager.player_choose_city)
	var targets = get_target_city_ids(city)
	DataManager.twinkle_citys = []
	var vstateId = -1
	var cityId = wait_for_choose_city(delta, "enter_barrack_menu", targets.keys())
	if cityId >= 0:
		var selected = clCity.city(cityId)
		vstateId = selected.get_vstate_id()
	if not vstateId in targets.values():
		var current = SceneManager.current_scene().get_curosr_point_city()
		if current > 0:
			var currentCity = clCity.city(current)
			var currentVstateId = currentCity.get_vstate_id()
			if not currentVstateId in [-1, city.get_vstate_id()]:
				DataManager.twinkle_citys = clCity.all_city_ids([currentVstateId])
		return
	
	DataManager.set_env("目标", vstateId)
	goto_step("selected")
	return

func effect_10127_selected() -> void:
	var targetVstateId = DataManager.get_env_int("目标")
	var targetVstate = clVState.vstate(targetVstateId)
	var capital = clCity.get_capital_city(targetVstateId)

	var msg = "前往{0}\n为{1}军【{2}】\n可否？".format([
		capital.get_full_name(), targetVstate.get_lord_name(),
		ske.skill_name,
	])
	play_dialog(actorId, msg, 0, 2001, true)
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_10127_confirmed() -> void:
	var targetVstateId = DataManager.get_env_int("目标")
	var targetVstate = clVState.vstate(targetVstateId)
	var capital = clCity.get_capital_city(targetVstateId)

	clCity.move_out(actorId)
	capital.add_actor(actorId)
	SkillHelper.add_actor_scene_skill(10000, actorId, TARGET_SKILL, 99999, actorId, ske.skill_name)

	var msg = "主公有命，莫敢不从\n日后相见，当各为其主\n（解锁【{0}】".format([
		TARGET_SKILL
	])
	play_dialog(actorId, msg, 3, 2002)
	DataManager.twinkle_citys = [DataManager.player_choose_city, capital.ID]
	return

func on_view_model_2002()->void:
	wait_for_yesno(FLOW_BASE + "_result")
	return

func effect_10127_result() -> void:
	var city = clCity.city(DataManager.player_choose_city)
	var targetVstateId = DataManager.get_env_int("目标")
	var targetVstate = clVState.vstate(targetVstateId)
	var capital = clCity.get_capital_city(targetVstateId)

	ske.affair_cd(99999)
	clVState.set_alliance(targetVstateId, city.get_vstate_id(), 12)

	var msg = "{0}转投{1}于{2}\n{1}与{3}结盟 12 个月".format([
		actor.get_name(), targetVstate.get_lord_name(),
		capital.get_full_name(), city.get_lord_name(),
	])
	play_dialog(-1, msg, 2, 2999)
	DataManager.twinkle_citys = clCity.all_city_ids([city.get_vstate_id(), targetVstateId])
	return

func get_target_city_ids(city:clCity.CityInfo)->Dictionary:
	var ret = {}
	for vs in clVState.all_vstates(true):
		if vs.id == city.get_vstate_id():
			continue
		var capital = clCity.get_capital_city(vs.id)
		if capital == null:
			continue
		ret[capital.ID] = vs.id
	return ret
