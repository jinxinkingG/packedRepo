extends "effect_10000.gd"

#纳粮主动技
#【纳粮】内政，主动技。你对本城乡绅进行强征，使本城立即获得X米，X＝你的政。发动一次本城统治度-1，每月限1次。

const EFFECT_ID = 10105
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_10105_start()->void:
	var cityId = self.get_working_city_id()
	var city = clCity.city(cityId)

	ske.affair_cd(1)
	var rice = city.add_rice(actor.get_politics())
	var loy = city.add_loyalty(-1)
	var msg = "此亦无奈之政"
	if rice > 0:
		msg += "\n（{0}米增加 {1}"
	if loy < 0:
		msg += "\n（{0}统治度 -{2}"
	msg = msg.format([
		city.get_full_name(), rice, abs(loy),
	])
	play_dialog(actorId, msg, 2, 2000)
	return

func on_view_model_2000()->void:
	SceneManager.show_cityInfo(true)
	wait_for_skill_result_confirmation()
	return
