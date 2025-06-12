extends "effect_10000.gd"

#助势主动技
#【助势】内政，主动技。消耗20体力才能发动。下个月，你方势力将作为第一个执行内政行动的势力。每3月限1次。

const EFFECT_ID = 10104
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_10104_start():
	if actor.get_hp() < 21:
		SceneManager.show_confirm_dialog("体力不足，尚需休养…", actorId, 3)
		LoadControl.set_view_model(2001)
		return
	SceneManager.show_cityInfo(false)
	SceneManager.show_confirm_dialog("寻机取势，何待惜身？", actorId)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_10104_2():
	var cityId = DataManager.player_choose_city
	var vstateId = clCity.city(cityId).get_vstate_id()
	ske.affair_cd(3)
	actor.set_hp(max(1, actor.get_hp() - 20))
	DataManager.set_env("优先行动势力", [vstateId, 0])
	var msg = "下月将优先行动\n{0}体力降为{1}".format([
		actor.get_name(), int(actor.get_hp()),
	])
	SceneManager.show_confirm_dialog(msg)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation()
	return
