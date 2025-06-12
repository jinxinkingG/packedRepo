extends "effect_10000.gd"

#放牲主动技
#【放牲】内政，主动技。退役军马赐予流民，帮助他们开垦田地，以此吸引流民，每月限3次。
#（1级马，人口+150；2级马，民忠+1，人口+400；3级和4级马，民忠+2，人口+800。）

const EFFECT_ID = 10057
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const EQUIP_LEVEL_DICT = {
	"1": 150,
	"2": 400,
	"3": 800,
	"4": 800,
}
const DEV_PROP = "人口"
const DEV_MAX = 999900
const EQUIP_TYPE = "坐骑"

func on_view_model_2000():
	wait_for_choose_item(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_10057_start():
	var cityId = DataManager.player_choose_city
	var city = clCity.city(cityId)
	if city.get_property(DEV_PROP) >= DEV_MAX:
		LoadControl._error("本城已无需开发" + DEV_PROP)
		return
	var items = []
	var values = []
	var vs = clVState.vstate(city.get_vstate_id())
	for item in vs.list_stored_equipments():
		var equip = item[0]
		if equip.type != EQUIP_TYPE:
			continue
		if not equip.level() in EQUIP_LEVEL_DICT:
			continue
		var msg = "{0} x{1}".format([equip.name(), item[1]])
		if equip.level() == "S":
			msg += "#C212,32,32"
		items.append(msg)
		values.append({
			"ID": equip.id,
			"类型": equip.type,
			"装备库数量": item[1],
		})
	if values.empty():
		LoadControl._error("装备库中已无可用" + EQUIP_TYPE)
		return
	set_env("列表值", values)
	var msg = "选择{0}\n退役军马，赐予流民".format([EQUIP_TYPE])
	SceneManager.show_unconfirm_dialog(msg, actorId)
	SceneManager.lsc_menu_top.set_lsc()
	SceneManager.lsc_menu_top.lsc.columns = 2
	SceneManager.lsc_menu_top.lsc.items = items
	SceneManager.lsc_menu_top.lsc._set_data()
	SceneManager.lsc_menu_top.show()
	SceneManager.lsc_menu_top.lsc.cursor_index = 0
	LoadControl.set_view_model(2000)
	return

func effect_10057_2():
	var item = get_env_dict("目标项")
	var equip = clEquip.equip(int(item["ID"]), item["类型"])
	SceneManager.hide_all_tool()
	var msg = "{0}已无用处\n退役军马，赐予流民，吸引人口，可否？".format([
		equip.name(),
	])
	SceneManager.show_yn_dialog(msg, actorId)
	LoadControl.set_view_model(2001)
	return

func effect_10057_3():
	var cityId = DataManager.player_choose_city
	var city = clCity.city(cityId)
	var item = get_env_dict("目标项")
	var equip = clEquip.equip(int(item["ID"]), item["类型"])
	var val = EQUIP_LEVEL_DICT[equip.level()]

	ske.affair_cost_limited_times(3)

	var prevVal = int(city.get_property(DEV_PROP))
	var vs = clVState.vstate(city.get_vstate_id())
	vs.remove_stored_equipment(equip)
	city.add_city_property(DEV_PROP, val)
	var msg = "退役一匹{0}，赐予流民\n{1}上升{2}".format([
		equip.name(),
		DEV_PROP, city.get_property(DEV_PROP) - prevVal
	])
	var loyalty = city.add_loyalty(int(val / 400))
	if loyalty > 0:
		msg += "，统治度上升{0}".format([loyalty])
	LoadControl._error(msg, actorId)
	return
