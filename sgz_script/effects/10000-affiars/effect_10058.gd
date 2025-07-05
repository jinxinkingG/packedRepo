extends "effect_10000.gd"

#寻骥主动技
#【寻骥】内政，主动技。消耗1枚命令书，若本城有在野武将，必定遇到武将，每月限一次。

const EFFECT_ID = 10058
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_10058_start():
	ske.affair_cd(1)
	var cityId = get_working_city_id()
	var unoffices = clCity.get_unoffice_actors(cityId)
	DataManager.player_choose_actor = actorId
	if cityId < 0 or unoffices.empty():
		LoadControl.end_script()
		LoadControl.load_script("affiars/town_search.gd")
		SceneManager.dialog_use_orderbook_animation("search_animation")
		return

	var cmd = DataManager.new_search_command(cityId, actorId)
	cmd.add_dialog("遇见一位前途无量之武将", actorId, 1)
	cmd.result = 5
	cmd.mood = 1
	cmd.foundActorId = unoffices[0]
	cmd.decide_actor_result()
	DataManager.twinkle_citys = [cityId]
	var msg = "世有千里马，岂能无伯乐？"
	SceneManager.play_affiars_animation(
		"Town_Search", "", false,
		msg, actorId, 2
	)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_10058_2():
	LoadControl.end_script()
	LoadControl.load_script("affiars/town_search.gd")
	SceneManager.dialog_use_orderbook_animation("search_report")
	return
