extends "effect_10000.gd"

#仿制主动技
#【仿制】内政，主动技。选择装备库的一件非S级的武器或防具，花费城内装备价格的金才能发动。所选装备数量+1。每月限一次。

const EFFECT_ID = 10087
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_10087_start()->void:
	var city = clCity.city(DataManager.player_choose_city)
	var ret = clCity.list_stored_equipments_paged(city.get_vstate_id(), false, true, ["武器", "防具"])
	var items = ret[0]
	var values = ret[1]
	if items.empty() or items[0] == "":
		SceneManager.show_confirm_dialog("库存为空，无可仿制")
		LoadControl.set_view_model(2999)
		return
	SceneManager.show_unconfirm_dialog("仿制何物？", actorId)
	SceneManager.bind_top_menu(items, values, 2)
	var page = DataManager.get_env_int("列表页码")
	var maxPage = DataManager.get_env_int("列表页数")
	if maxPage > 0:
		SceneManager.lsc_menu_top.lsc.set_pager(page, maxPage)
	LoadControl.set_view_model(2000)
	DataManager.set_env("CURRENT_FLOW", FLOW_BASE + "_start")
	return

func on_view_model_2000()->void:
	Global.wait_for_choose_equip(FLOW_BASE + "_confirm", "back_to_skill_menu")
	return

func effect_10087_confirm()->void:
	var item = DataManager.get_env_dict("目标项")
	var equip = clEquip.equip(int(item["ID"]), str(item["类型"]))
	if equip.level() == "S":
		play_dialog(actorId, "不可复制 S 装", 2, 2999)
		return
	var city = clCity.city(DataManager.player_choose_city)
	if city.get_gold() < equip.price():
		var msg = "城市金不足\n需金 {0}".format([equip.price()])
		play_dialog(actorId, msg, 2, 2999)
		return
	var msg = "仿制一件「{0}」\n需金 {1}\n可否？".format([
		equip.name(), equip.price(),
	])
	play_dialog(actorId, msg, 2, 2001, true)
	DataManager.cityInfo_type = 3
	SceneManager.show_cityInfo(true)
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_copy")
	return

func effect_10087_copy()->void:
	var item = DataManager.get_env_dict("目标项")
	var equip = clEquip.equip(int(item["ID"]), str(item["类型"]))
	var city = clCity.city(DataManager.player_choose_city)
	city.add_gold(-equip.price())
	var vs = clVState.vstate(city.get_vstate_id())
	ske.affair_cd(1)
	vs.add_stored_equipment(equip)
	var msg = "匠心独运，制得「{0}」\n已置入装备仓库\n{1}金 -{2}，现为{3}".format([
		equip.name(), city.get_full_name(), equip.price(), city.get_gold(),
	])
	play_dialog(actorId, msg, 1, 2999)
	DataManager.cityInfo_type = 3
	SceneManager.show_cityInfo(true)
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation()
	return
