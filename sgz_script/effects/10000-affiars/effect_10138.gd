extends "effect_10000.gd"

const EFFECT_ID = 10138
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_10007() -> bool:
	if DataManager.get_current_scene_id() != 10000:
		return false
	var cityId = DataManager.player_choose_city
	var city = clCity.city(cityId)
	var equipType = DataManager.get_env_str("大类型")
	var equipId = DataManager.get_env_int("购买装备")
	var equip = clEquip.equip(equipId, equipType)
	var remaining = equip.remaining()
	if remaining == 0:
		return false
	if not equip.actor_can_use(actorId):
		return false
	var price = equip.price_for(cityId)
	var gold = city.get_gold()
	return price > gold and gold > 0
		
func effect_10138_start()->void:
	SceneManager.show_confirm_dialog("将军恕罪\n军资不足以购买此物", -1, 2, true)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_confirm")
	return

func effect_10138_confirm()->void:
	ske.affair_cd(1)
	var msg = "军国大事，岂容商贾放肆！\n（发动【强买】"
	SceneManager.show_confirm_dialog(msg, actorId, 0)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_done")
	return

func effect_10138_done()->void:
	DataManager.set_env("装备数量", 1)
	skill_end_clear(true)
	FlowManager.add_flow("load_script|affiars/fair_equipshop.gd")
	FlowManager.add_flow("equip_confirm")
	return
