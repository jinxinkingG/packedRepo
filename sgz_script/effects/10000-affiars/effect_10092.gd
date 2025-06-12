extends "effect_10000.gd"

#典吏主动技
#【典吏】内政，主动技。你可以消耗一本非S级的书类道具，令本城太守经验+150，每月限一次。

const EFFECT_ID = 10092
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const EXP_GAIN = 150

func effect_10092_start():
	var cityId = get_working_city_id()
	if cityId < 0:
		skill_end_clear()
		FlowManager.add_flow("player_ready")
		return
	var city = clCity.city(cityId)
	var leader = ActorHelper.actor(city.get_leader_id())
	var items = []
	var values = []
	var vs = clVState.vstate(city.get_vstate_id())
	for item in vs.list_stored_equipments():
		var equip = item[0]
		if equip.type != "道具":
			continue
		if equip.subtype() != "书":
			continue
		if equip.level_score() >= 9:
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
	DataManager.set_env("列表值", values)
	var msg = "选择典籍，赠予{0}".format([
		leader.get_name(),
	])
	if leader.actorId == actorId:
		msg = "选择典籍，深入研读"
	SceneManager.show_unconfirm_dialog(msg, actorId)
	SceneManager.bind_top_menu(items, values, 1)
	LoadControl.set_view_model(2000)
	return


func on_view_model_2000():
	wait_for_choose_item(FLOW_BASE + "_2")
	return

func effect_10092_2():
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var leader = ActorHelper.actor(city.get_leader_id())
	var item = DataManager.get_env_dict("目标项")
	var equip = clEquip.equip(int(item["ID"]), item["类型"])
	SceneManager.hide_all_tool()
	var msg = "失去一本库藏《{0}》\n令{1}经验 +{2}\n可否？".format([
		equip.name(), leader.get_name(), EXP_GAIN,
	])
	play_dialog(actorId, msg, 1, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_10092_3():
	var cityId = DataManager.player_choose_city
	var city = clCity.city(cityId)
	var leader = ActorHelper.actor(city.get_leader_id())
	var item = DataManager.get_env_dict("目标项")
	var equip = clEquip.equip(int(item["ID"]), item["类型"])

	ske.affair_cd(1)

	var vs = clVState.vstate(city.get_vstate_id())
	vs.remove_stored_equipment(equip)
	
	var expGain = leader.add_exp(EXP_GAIN)
	var msg = "《{0}》之中，自有真义\n{1}善纳之\n（{2}经验现为 {4}"
	if leader.actorId == actorId:
		msg = "《{0}》之中，自有真义\n吾当时习之\n（{2}经验现为 {4}"
	msg = msg.format([
		equip.name(), DataManager.get_actor_honored_title(leader.actorId, actorId),
		leader.get_name(), expGain, leader.get_exp(),
	])
	play_dialog(actorId, msg, 1, 2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return

