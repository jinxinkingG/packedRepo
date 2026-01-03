extends "effect_10000.gd"

# 堪亲主动技
#【堪亲】内政，主动技。你非太守，可选择本势力内与你同姓的武将作太守的城市，无视连线移动至目标城，可同时带上本城另一位普通武将。每月限1次。

const EFFECT_ID = 10139
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_10139_start() -> void:
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var vstateId = city.get_vstate_id()

	var targetCityIds = []
	for targetCityId in clCity.all_city_ids([vstateId]):
		if targetCityId == cityId:
			continue
		var targetCity = clCity.city(targetCityId)
		if targetCity.get_leader().get_first_name() != actor.get_first_name():
			continue
		targetCityIds.append(targetCityId)
	if targetCityIds.empty():
		var msg = "没有同姓太守城市\n不可发动【{0}】".format([ske.skill_name])
		play_dialog(actorId, msg, 2, 2999)
		return
	# 记录可移动的城市
	ske.affair_set_skill_val(targetCityIds, 1)

	SceneManager.hide_all_tool()
	SceneManager.clear_bottom()
	DataManager.twinkle_citys = targetCityIds
	SceneManager.current_scene().cursor.show()
	SceneManager.current_scene().set_city_cursor_position(cityId)
	SceneManager.show_unconfirm_dialog("请选择目标城市")
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000_delta(delta:float) -> void:
	var targetCityIds = ske.affair_get_skill_val_int_array()
	var targetCityId = wait_for_choose_city(delta, "skill_list", targetCityIds)
	if targetCityId < 0:
		return
	var targetCity = clCity.city(targetCityId)
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var vstateId = city.get_vstate_id()
	if targetCity.get_vstate_id() != vstateId:
		SceneManager.show_unconfirm_dialog("此非我方城池")
		return
	if targetCity.get_leader().get_first_name() != actor.get_first_name():
		SceneManager.show_unconfirm_dialog("此非同姓太守城市")
		return
	ske.affair_set_skill_val([targetCityId], 1)
	goto_step("selected")
	return

func effect_10139_selected() -> void:
	var targetCityId = ske.affair_get_skill_val_int_array()[0]
	var targetCity = clCity.city(targetCityId)
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var vstateId = city.get_vstate_id()

	# 默认自己去

	var withIds = city.get_actor_ids()
	withIds.erase(actorId)
	withIds.erase(city.get_lord_id())
	withIds.erase(city.get_leader_id())
	if withIds.empty():
		goto_step("go")
		return

	var msg = "可协同其他武将移动至目标城"
	SceneManager.show_actorlist_army(withIds, true, msg, false)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001() -> void:
	if not wait_for_choose_actor(FLOW_BASE + "_go", false, true):
		return
	var targetId = SceneManager.actorlist.get_select_actor()
	if targetId >= 0:
		var setting = ske.affair_get_skill_val_int_array()
		setting.append(targetId)
		ske.affair_set_skill_val(setting, 1)
	goto_step("go")
	return

func effect_10139_go() -> void:
	var cityId = get_working_city_id()
	var setting = ske.affair_get_skill_val_int_array()
	var targetCityId = setting[0]
	var targetCity = clCity.city(targetCityId)
	var withId = -1
	if setting.size() > 1:
		withId = setting[1]

	var msg = "{0}久违矣，正当探问".format([
		DataManager.get_actor_honored_title(targetCity.get_leader_id(), actorId),
	])
	DataManager.twinkle_citys = [cityId, targetCityId]
	SceneManager.play_affiars_animation("Town_Move", "", false, msg, actorId, 1)
	LoadControl.set_view_model(2002)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_move")
	return

func effect_10139_move() -> void:
	var setting = ske.affair_get_skill_val_int_array()
	var targetCityId = setting[0]
	var targetCity = clCity.city(targetCityId)
	var withId = -1
	if setting.size() > 1:
		withId = setting[1]

	var leaderId = targetCity.get_leader_id()

	ske.affair_cd(1)
	clCity.move_to(actorId, targetCityId)
	var msg = DataManager.get_actor_honored_title(actorId, leaderId)
	if withId >= 0:
		clCity.move_to(withId, targetCityId)
		msg += "、" + DataManager.get_actor_honored_title(withId, leaderId)
	msg += "，来之何迟"
	msg += "\n（{0}{1}{2}移动到{3}".format([
		actor.get_name(), "、" if withId >= 0 else "",
		ActorHelper.actor(withId).get_name() if withId >= 0 else "",
		targetCity.get_full_name(),
	])
	targetCity.attach_free_dialog(msg, targetCity.get_leader_id(), 1, [targetCityId], 1)
	skill_end_clear()
	DataManager.player_choose_city = targetCityId
	return
