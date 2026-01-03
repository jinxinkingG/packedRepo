extends "effect_10000.gd"

#募勇主动技
#【募勇】内政，太守主动技。你张贴告示，进行招募乡勇：本城后备兵+X。你为君主时X=你方城池数*500；你非君主时X=500，每三个月限一次。

const EFFECT_ID = 10136
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_10136_start() -> void:
	var cityId = get_working_city_id()
	if cityId < 0:
		goto_step("end")
		return
	var cityIds = [cityId]
	var city = clCity.city(cityId)
	var msg = "于{0}"
	if city.get_lord_id() == actorId:
		msg = "全境"
		cityIds = clCity.all_city_ids([city.get_vstate_id()])
	msg += "张榜求士，招募义勇"
	msg = msg.format([city.get_full_name()])

	play_dialog(actorId, msg, 2, 2000)
	DataManager.twinkle_citys = cityIds
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_confirmed")
	return

func effect_10136_confirmed() -> void:
	var cityId = get_working_city_id()
	var x = 1
	var city = clCity.city(cityId)
	if city.get_lord_id() == actorId:
		x = clCity.all_cities([city.get_vstate_id()]).size()
	x *= 500
	ske.affair_cd(3)
	x = city.add_city_property("后备兵", x)
	var msg = "{0}后备兵+{1}".format([city.get_full_name(), x])
	play_dialog(actorId, msg, 1, 2999)
	SceneManager.show_cityInfo(true, cityId, 2)
	return

func effect_10136_end() -> void:
	skill_end_clear()
	FlowManager.add_flow("player_ready")
	return
