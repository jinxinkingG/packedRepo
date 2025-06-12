extends "effect_10000.gd"

#废柴主动技
#【废柴】内政,主动技。你可以将装备库中的书类道具送给民众，民众可以拿竹简去烧火做饭，提高民忠，每月限3次。
#（括号内不写进游戏内：兵书、春秋、史记＝3点民忠，六韬＝5点。）

const EFFECT_ID = 10039
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const BOOKS_DICT = {
	"兵书": 3,
	"春秋": 3,
	"史记": 3,
	"六韬": 5,
}
const DEV_PROP = "统治度"
const DEV_MAX = 100
const EQUIP_TYPE = "道具"
const HELP_TARGET = "民众"

func on_view_model_2000():
	wait_for_choose_item(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_10039_start():
	var cityId = DataManager.player_choose_city
	var city = clCity.city(cityId)
	if city.get_property(DEV_PROP) >= DEV_MAX:
		LoadControl._error("民众均已心悦诚服")
		return
	var items = []
	var values = []
	var vs = clVState.vstate(city.get_vstate_id())
	for item in vs.list_stored_equipments():
		var equip = item[0]
		if equip.type != EQUIP_TYPE:
			continue
		if equip.subtype() != "书":
			continue
		if not equip.name() in BOOKS_DICT:
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
		LoadControl._error("装备库中已无可用典籍")
		return
	set_env("列表值", values)
	var msg = "选择典籍，赠予民众"
	SceneManager.show_unconfirm_dialog(msg, actorId)
	SceneManager.lsc_menu_top.set_lsc()
	SceneManager.lsc_menu_top.lsc.columns = 2
	SceneManager.lsc_menu_top.lsc.items = items
	SceneManager.lsc_menu_top.lsc._set_data()
	SceneManager.lsc_menu_top.show()
	SceneManager.lsc_menu_top.lsc.cursor_index = 0
	LoadControl.set_view_model(2000)
	return

func effect_10039_2():
	var item = get_env_dict("目标项")
	var equip = clEquip.equip(int(item["ID"]), item["类型"])
	SceneManager.hide_all_tool()
	var msg = "纵熟读{0}百遍\n亦难解百姓疾苦\n赠予民众生火做饭，可否？".format([
		equip.name(),
	])
	SceneManager.show_yn_dialog(msg, actorId)
	LoadControl.set_view_model(2001)
	return

func effect_10039_3():
	var cityId = DataManager.player_choose_city
	var city = clCity.city(cityId)
	var item = get_env_dict("目标项")
	var equip = clEquip.equip(int(item["ID"]), item["类型"])
	var val = BOOKS_DICT[equip.name()]

	ske.affair_cost_limited_times(3)

	var prevVal = int(city.get_property(DEV_PROP))
	var vs = clVState.vstate(city.get_vstate_id())
	vs.remove_stored_equipment(equip)
	city.add_city_property(DEV_PROP, val)
	var msg = "失去一本{0}\n民众感念恩德\n{1}上升{2}".format([
		equip.name(),
		DEV_PROP, city.get_property(DEV_PROP) - prevVal
	])
	LoadControl._error(msg, actorId)
	return
