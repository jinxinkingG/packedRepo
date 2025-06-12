extends "effect_10000.gd"

#济乡主动技
#【济乡】内政，主动技。你的经验-500，你所在城民忠+15，每月限1次。（经验不足无法发动）

const EFFECT_ID = 10074
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_EXP = 500
const LOYALTY_UP = 15

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

func on_view_model_2009():
	wait_for_skill_result_confirmation()
	return

func effect_10074_start():
	var cityId = get_working_city_id()
	if cityId < 0:
		var msg = "不可"
		SceneManager.show_confirm_dialog(msg)
		LoadControl.set_view_model(2009)
		return
	var city = clCity.city(cityId)
	if city.get_loyalty() > 100 - LOYALTY_UP:
		var msg = "{0}四野祥和\n无须【{1}】".format([
			city.get_full_name(), ske.skill_name,
		])
		SceneManager.show_confirm_dialog(msg, actorId, 1)
		SceneManager.show_cityInfo(true, -1, 0)
		LoadControl.set_view_model(2009)
		return
		
	if actor.get_exp() <= COST_EXP:
		var msg = "经验不足，须 >= {0}".format([COST_EXP])
		SceneManager.show_confirm_dialog(msg)
		LoadControl.set_view_model(2009)
		return

	var msg = "身体力行，接济乡邻\n消耗{0}经验\n可否？".format([COST_EXP])
	SceneManager.show_yn_dialog(msg, actor.actorId)
	DataManager.cityInfo_type = 0
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(2000)
	return

func effect_10074_2():
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)

	ske.affair_cd(1)
	actor.set_exp(actor.get_exp() - COST_EXP)
	city.add_loyalty(LOYALTY_UP)
	
	var msg = "乡邻安居乐业，固所愿也\n（{0}的经验减少{1}\n统治度上升{2}".format([
		actor.get_name(), COST_EXP, LOYALTY_UP,
	])
	SceneManager.show_confirm_dialog(msg, actor.actorId, 1)
	DataManager.cityInfo_type = 0
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(2009)
	return
