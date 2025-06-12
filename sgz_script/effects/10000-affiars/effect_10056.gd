extends "effect_10000.gd"

#工坊主动技
#【工坊】内政，主动技。你可以把防具拆掉，重新废物利用，做成产业工具，提高产业值，每月限3次。
#（括号内不写进游戏内：1级防具＝提高3点。2级防具＝提高6点。3级防具＝提高12点。4级防具＝提高18点，5级防具＝提高25点）

const EFFECT_ID = 10056
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const EQUIP_LEVEL_DICT = {
	"1": 3,
	"2": 6,
	"3": 12,
	"4": 18,
	"5": 25,
}
const DEV_PROP = "产业"
const DEV_MAX = 999
const EQUIP_TYPE = "防具"
const REGEN_TARGET = "工具"
const HELP_TARGET = "商户"

func on_view_model_2000():
	wait_for_choose_item(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_10056_start():
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
	var msg = "选择{0}\n重铸为{1}，赠予{2}".format([EQUIP_TYPE, REGEN_TARGET, HELP_TARGET])
	SceneManager.show_unconfirm_dialog(msg, actorId)
	SceneManager.lsc_menu_top.set_lsc()
	SceneManager.lsc_menu_top.lsc.columns = 2
	SceneManager.lsc_menu_top.lsc.items = items
	SceneManager.lsc_menu_top.lsc._set_data()
	SceneManager.lsc_menu_top.show()
	SceneManager.lsc_menu_top.lsc.cursor_index = 0
	LoadControl.set_view_model(2000)
	return

func effect_10056_2():
	var item = get_env_dict("目标项")
	var equip = clEquip.equip(int(item["ID"]), item["类型"])
	SceneManager.hide_all_tool()
	var msg = "{0}已无用处\n重铸为{1}，赠予{2}提高开发度，可否？".format([
		equip.name(), REGEN_TARGET, HELP_TARGET
	])
	SceneManager.show_yn_dialog(msg, actorId)
	LoadControl.set_view_model(2001)
	return

func effect_10056_3():
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
	var msg = "将一件{0}重铸为{1}发放，{2}生产力提高\n{3}上升{4}".format([
		equip.name(), REGEN_TARGET, HELP_TARGET,
		DEV_PROP, city.get_property(DEV_PROP) - prevVal
	])
	LoadControl._error(msg, actorId)
	return
