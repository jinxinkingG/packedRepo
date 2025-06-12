extends "effect_10000.gd"

#宴请主动技
#【宴请】内政，太守主动技。你可以选择本城1~10位本城武将，宴请诸将，使每位武将忠+8。每月限一次

const EFFECT_ID = 10045
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_GOLD_BASE = 100
const COST_GOLD_PER = 50
const LOYALTY_UP = 8

func effect_10045_start():
	var cityId = DataManager.player_choose_city
	var city = clCity.city(cityId)
	var actors = city.get_actor_ids()
	if actors.size() <= 1:
		var msg = "凄凄戚戚，无客可宴"
		play_dialog(actorId, msg, 3, 2999)
		return
	var targets = []
	for targetId in actors:
		var actor = ActorHelper.actor(targetId)
		if actor.get_loyalty() >= 99:
			continue
		if targetId == self.actorId:
			continue
		targets.append(targetId)
	if targets.empty():
		var msg = "众志成城，正当奋发\n何暇宴饮？"
		play_dialog(actorId, msg, 2, 2999)
		return
	SceneManager.show_actorlist_develop(targets, true, "宴请何人？(0/10)")
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	if not wait_for_choose_actor("player_ready", false, true):
		return
	var lst = SceneManager.actorlist
	if Input.is_action_just_pressed("EMU_START"):
		var picked = lst.get_picked_actors()
		var all = lst.get_actor_ids()
		all.erase(-1)
		if picked.size() == all.size():
			lst.move_to(-1)
			return
		for targetId in all:
			if targetId in picked:
				continue
			lst.set_actor_picked(targetId)
		var msg = "宴请何人？({0}/10)".format([lst.get_picked_actors().size()])
		lst.speak(msg, true)
		return
	var targetId = lst.get_select_actor()
	if targetId >= 0:
		lst.set_actor_picked(targetId)
		var msg = "宴请何人？({0}/10)".format([lst.get_picked_actors().size()])
		lst.speak(msg, true)
		return
	var picked = lst.get_picked_actors()
	if picked.empty():
		return
	LoadControl.set_view_model(-1)
	DataManager.set_env("目标列表", picked)
	goto_step("2")
	return

func effect_10045_2():
	var cityId = DataManager.player_choose_city
	var city = clCity.city(cityId)
	var targetIds = DataManager.get_env_int_array("目标列表")
	var cost = COST_GOLD_BASE + targetIds.size() * COST_GOLD_PER
	if city.get_gold() < cost:
		LoadControl._error("城市金不足，需{0}".format([cost]), self.actorId, 3)
		return
	SceneManager.hide_all_tool()
	var msg = "花费{0}金，宴请{1}，可否？".format([
		cost, "、".join(get_actor_names(targetIds))
	])
	SceneManager.show_yn_dialog(msg, actorId)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_3", "player_ready")
	return

func effect_10045_3():
	var cityId = DataManager.player_choose_city
	var city = clCity.city(cityId)
	var targetIds = DataManager.get_env_int_array("目标列表")
	var cost = COST_GOLD_BASE + targetIds.size() * COST_GOLD_PER
	ske.affair_cd(1)
	city.add_gold(-cost)
	for targetId in targetIds:
		var actor = ActorHelper.actor(targetId)
		actor.set_loyalty(min(99, actor.get_loyalty() + LOYALTY_UP))
	var msg = "接着奏乐……接着舞…嗝~\n（{0}忠上升，城市金现为{1}".format([
		"、".join(get_actor_names(targetIds)), city.get_gold()
	])
	targetIds.shuffle()
	play_dialog(targetIds[0], msg, 1, 2999)
	return
