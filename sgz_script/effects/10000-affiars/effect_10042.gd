extends "effect_10000.gd"

#责罚主动技
#【责罚】内政,太守主动技。你可指定一个自身以外的武将发动。目标忠-10，城内金+50，每月限3次。

const EFFECT_ID = 10042
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const EXCUSES = [
	"时有怨谤之言",
	"常怀异心",
	"暗结外邦",
	"不恤士卒",
	"荒废政事",
	"不思进取",
	"与同僚不睦",
]
const FINE_GOLD = 50
const TIMES_LIMIT = 3

func effect_10042_start():
	var cityId = DataManager.player_choose_city
	var city = clCity.city(cityId)
	var targets = []
	for targetId in city.get_actor_ids():
		if targetId == actorId:
			continue
		var loyalty = ActorHelper.actor(targetId).get_loyalty()
		if loyalty == 100:
			continue
		if loyalty <= 0:
			continue
		targets.append(targetId)
	if targets.empty():
		SceneManager.show_confirm_dialog("无人可以责罚\n还当反求诸己", actorId, 3)
		LoadControl.set_view_model(2999)
		return
	SceneManager.show_actorlist_army(targets, false, "责罚何人？", false)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	if not wait_for_choose_actor("player_ready"):
		return
	DataManager.set_env("目标", SceneManager.actorlist.get_select_actor())
	goto_step("2")
	return

func effect_10042_2():
	var targetId = DataManager.get_env_int("目标")
	SceneManager.hide_all_tool()
	var msg = "对{0}处以{1}罚金可否？".format([
		ActorHelper.actor(targetId).get_name(),
		FINE_GOLD,
	])
	SceneManager.show_yn_dialog(msg, actorId)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_3", "player_ready")
	return

func effect_10042_3():
	var cityId = DataManager.player_choose_city
	var city = clCity.city(cityId)
	var targetId = DataManager.get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)

	ske.affair_cost_limited_times(3)
	targetActor.set_loyalty(targetActor.get_loyalty() - 10)
	city.add_gold(FINE_GOLD)
	var reasons = EXCUSES.duplicate()
	reasons.shuffle()
	var reason = reasons[0]
	var msg = "近来风闻\n{0}{1}\n略施小惩，还望大诫！".format([
		DataManager.get_actor_naughty_title(targetId, actorId),
		reason
	])
	SceneManager.show_confirm_dialog(msg, actorId, 0)
	LoadControl.set_view_model(2002)
	return

func on_view_model_2002()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_10042_4():
	var cityId = DataManager.player_choose_city
	var city = clCity.city(cityId)
	var targetId = DataManager.get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var msg = "…… ……\n（{0}忠降为{1}\n（城市金现为{2}".format([
		targetActor.get_name(), targetActor.get_loyalty(), city.get_gold(),
	])
	SceneManager.show_confirm_dialog(msg, targetId, 0)
	LoadControl.set_view_model(2999)
	return
