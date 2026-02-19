extends "effect_10000.gd"

#敛财效果
#【敛财】内政，主动技。使用后，你的永久标记[金]+X，且产业和土地分别-（X/4），民忠-X/50，同时，你死亡或者被俘虏时，击杀方，获得杨松永久标记[金]等数量的金。X=（本城产业值+土地值）。

const EFFECT_ID = 10022
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const FLAG_EFF_ID = 10023 # 在「金猪」中存储标记
const FLAG_NAME = "金"

func effect_10022_start():
	var city = clCity.city(DataManager.player_choose_city)
	var x = city.get_land() + city.get_eco()
	if x < 100:
		var msg = "民力已尽..."
		play_dialog(actorId, msg, 3, 2999)
		return

	ske.affair_cd(1)
	city.add_city_property("土地", -city.get_land() / 4)
	city.add_city_property("产业", -city.get_eco() / 4)
	city.add_loyalty(-ceil(x / 50))
	ske.add_skill_flags(10000, FLAG_EFF_ID, FLAG_NAME, x)
	var msg = "藏富于民，何如取之于民"
	play_dialog(actorId, msg, 1, 2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_10022_2():
	var city = clCity.city(DataManager.player_choose_city)
	var x = ske.get_skill_flags(10000, FLAG_EFF_ID, FLAG_NAME)
	var msgs = []
	msgs.append("{0}的 [金] 增为 {1}".format([actor.get_name(), x]))
	msgs.append("土地变 {0}，产业变 {1}".format([city.get_land(), city.get_eco()]))
	msgs.append("统治度降为 {0}".format([city.get_loyalty()]))
	play_dialog(-1, "\n".join(msgs), 2, 2999)
	return
