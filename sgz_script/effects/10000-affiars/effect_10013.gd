extends "effect_10000.gd"

#劫民效果
#【劫民】内政，主动技。使用后，金+150和宝+1，同时人口-200，民忠-10。每月限1次

const EFFECT_ID = 10013
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_10013_start()->void:
	var city = clCity.city(DataManager.player_choose_city)
	if city.get_loyalty() < 10 or city.get_pop() < 200:
		SceneManager.show_confirm_dialog("民力已尽……", actorId, 3)
		LoadControl.set_view_model(2999)
		return

	ske.affair_cd(1)
	city.add_loyalty(-10)
	city.add_city_property("人口", -200)
	city.add_gold(150)
	city.add_city_property("宝", 1)
	SceneManager.show_confirm_dialog("无知小民\n还不快快献于本将！", actorId, 0)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_10013_2():
	var city = clCity.city(DataManager.player_choose_city)
	var msgs = []
	msgs.append("统治度降为 {0}".format([city.get_loyalty()]))
	msgs.append("人口降为 {0}".format([city.get_pop()]))
	msgs.append("获得金 150，宝 1")
	SceneManager.show_confirm_dialog("\n".join(msgs))
	LoadControl.set_view_model(2999)
	return
