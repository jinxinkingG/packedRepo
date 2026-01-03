extends "effect_10000.gd"

# 休兵主动技
#【休兵】内政，君主主动技。指定一个你方城池，该城后备兵力的50%解甲归田，成为该城池的人口。该城池：金增加“该解甲归田兵力/10”，民忠增加“该解甲归田兵力/1000”。每3个月限一次。

const EFFECT_ID = 10140
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_10140_start() -> void:
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var vstateId = city.get_vstate_id()

	var targetCityIds = []
	for targetCityId in clCity.all_city_ids([vstateId]):
		var targetCity = clCity.city(targetCityId)
		if targetCity.get_backup_soldiers() <= 1:
			continue
		targetCityIds.append(targetCityId)
	if targetCityIds.empty():
		var msg = "没有可【{0}】的城市".format([ske.skill_name])
		play_dialog(actorId, msg, 2, 2999)
		return
	# 记录可选择的城市
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
	if not targetCityId in targetCityIds:
		SceneManager.show_unconfirm_dialog("此非可【{0}】城市".format([ske.skill_name]))
		return
	ske.affair_set_skill_val([targetCityId], 1)
	goto_step("selected")
	return

func effect_10140_selected() -> void:
	var targetCityId = ske.affair_get_skill_val_int_array()[0]
	var targetCity = clCity.city(targetCityId)

	var soldiers = targetCity.get_backup_soldiers()
	var pop = int(soldiers / 2)
	pop = targetCity.add_city_property("人口", pop)
	var gold = targetCity.add_city_property("金", int(pop / 10))
	var loyalty = targetCity.add_city_property("统治度", int(pop / 1000))
	targetCity.add_city_property("后备兵", -pop)
	ske.affair_cd(3)
	var msg = "{0} {1}后备兵解甲归田\n人口增加至{2}\n金增加{3}，民忠增加{4}".format([
		targetCity.get_name(), pop, targetCity.get_pop(), gold, loyalty,
	])
	targetCity.attach_free_dialog(msg, targetCity.get_leader_id(), 2, [targetCityId])
	msg = "偃武修文，恢复生产"
	play_dialog(actorId, msg, 1, 2999)
	return
