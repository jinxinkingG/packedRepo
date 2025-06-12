extends "effect_10000.gd"

#推心主动技
#【推心】内政，主动技。若你的忠≥90，选择所在城中1名忠＜你的武将为目标，消耗20点体力发动。目标武将忠上升5点。每月限一次。

const EFFECT_ID = 10088
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const EFFECT_CHOOSE_ACTOR = "内政." + str(EFFECT_ID) + ".武将"
const LOYALTY_UP = 5
const HP_COST = 20

func effect_10088_start()->void:
	var loyalty = actor.get_loyalty()
	if loyalty < 90:
		play_dialog(actorId, "心存疑忌，何以推心？\n（自身忠诚不足", 3, 2999)
		return
	if actor.get_hp() <= HP_COST:
		play_dialog(actorId, "形神俱疲，何以推心？\n（体力不足", 3, 2999)
		return
	var city = clCity.city(DataManager.player_choose_city)
	var targets = []
	for targetId in city.get_actor_ids():
		if targetId == actorId:
			continue
		if ActorHelper.actor(targetId).get_loyalty() >= min(99, loyalty):
			continue
		targets.append(targetId)
	if targets.empty():
		play_dialog(actorId, "众志成城，主公勿忧", 1, 2999)
		return
	var msg = "对何人发动【{0}】？".format([ske.skill_name])
	SceneManager.show_actorlist_army(targets, false, msg, false)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	if wait_for_choose_actor():
		var actors = SceneManager.actorlist.actorId_list
		var idx = SceneManager.actorlist.cursor_index
		if idx < 0 or idx >= actors.size():
			goto_step("start")
			return
		var targetId = actors[idx]
		DataManager.set_env(EFFECT_CHOOSE_ACTOR, targetId)
		goto_step("perform")
	return

func effect_10088_perform()->void:
	var targetId = DataManager.get_env_int(EFFECT_CHOOSE_ACTOR)
	var msg = "近闻足下似不如意？\n我主创业艰难，然志在天下\n{0}终有申志之期".format([
		DataManager.get_actor_honored_title(targetId, actorId),
	])
	SceneManager.play_affiars_animation("Strategy_Talking", "", false, msg, actorId)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_confirmed")
	return

func effect_10088_confirmed()->void:
	var targetId = DataManager.get_env_int(EFFECT_CHOOSE_ACTOR)
	var targetActor = ActorHelper.actor(targetId)
	var msg = "{0}笃诚，能无所感？\n诚以待人，毅以处事\n大丈夫当如是".format([
		DataManager.get_actor_honored_title(actorId, targetId),
		DataManager.get_actor_self_title(targetId),
	])
	play_dialog(targetId, msg, 1, 2002)
	return

func on_view_model_2002()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_report")
	return

func effect_10088_report()->void:
	var targetId = DataManager.get_env_int(EFFECT_CHOOSE_ACTOR)
	var targetActor = ActorHelper.actor(targetId)
	ske.affair_cd(1)
	targetActor.set_loyalty(min(99, targetActor.get_loyalty() + LOYALTY_UP))
	actor.set_hp(int(ceil(actor.get_hp() - HP_COST)))
	var msg = "{0}忠+{1}，现为{2}\n{3}体力-{4}，现为{5}".format([
		targetActor.get_name(), LOYALTY_UP, targetActor.get_loyalty(),
		actor.get_name(), HP_COST, actor.get_hp(),
	])
	play_dialog(-1, msg, 2, 2999)
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation()
	return
