extends "effect_10000.gd"

#狮血主动技，修复兽带狮盔

const EFFECT_ID = 10089
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_GOLD = 50
const BROKEN_ID = StaticManager.SUIT_ID_SHIKUI_BROKEN
const RECOVERED_ID = StaticManager.SUIT_ID_SHIKUI

func on_trigger_10001()->bool:
	# 过月自动修复
	var cityId = get_working_city_id()
	if cityId < 0:
		return false
	if actor.get_suit().id != BROKEN_ID:
		return false
	var city = clCity.city(cityId)
	if city.get_gold() < COST_GOLD:
		return false
	city.add_gold(-COST_GOLD)
	actor.set_equip(clEquip.equip(RECOVERED_ID, "防具"))
	var msg = "花费{0}金\n[{1}]已修复".format([
		COST_GOLD, actor.get_suit().name(),
	])
	city.attach_free_dialog(msg, actorId, 1)
	return false

func on_trigger_20034()->bool:
	# 无尽模式过关自动修复
	if actor.get_suit().id != BROKEN_ID:
		return false
	actor.set_equip(clEquip.equip(RECOVERED_ID, "防具"))
	return false

func effect_10089_start()->void:
	var city = clCity.city(DataManager.player_choose_city)
	if city.get_gold() < COST_GOLD:
		play_dialog(actorId, "城内并无足够金钱", 3, 2999)
		return
	if actor.get_suit().id != BROKEN_ID:
		play_dialog(actorId, "并未装备破损的狮盔", 2, 2999)
		return
	city.add_gold(-COST_GOLD)
	actor.set_equip(clEquip.equip(RECOVERED_ID, "防具"))
	var msg = "花费{0}金修复\n{1}已恢复活力\n（{2}金剩余：{3}）".format([
		COST_GOLD, actor.get_suit().name(), city.get_full_name(), city.get_gold(),
	])
	play_dialog(actorId, msg, 1, 2999)
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation()
	return
