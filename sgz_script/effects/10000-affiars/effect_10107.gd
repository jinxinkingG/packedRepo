extends "effect_10000.gd"

#定品主动技
#【定品】内政，主动技。你方势力不少于3座城池时，你可以发动：消耗1000金，依次指定本城3个武将，令其兵力上限提升至2500、2200、2000，并维持一年，每年限1次。

const EFFECT_ID = 10107
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const MIN_CITIES = 3
const GOLD_COST = 1000

func effect_10107_start():
	var cityId = get_working_city_id()
	if cityId < 0:
		goto_step("end")
		return
	var city = clCity.city(cityId)
	if city.get_gold() < GOLD_COST:
		var msg = "{0}资金不足，需 >= {1}".format([
			city.get_full_name(), GOLD_COST,
		])
		play_dialog(actorId, msg, 2, 2999)
		return
	if clCity.all_cities([city.get_vstate_id()]).size() < MIN_CITIES:
		var msg = "我军初创，人心未附\n未得其时也\n（需城池数 >= {0}".format([MIN_CITIES])
		play_dialog(actorId, msg, 2, 2999)
		return
	var lordId = city.get_lord_id()
	var actorIds = city.get_actor_ids()
	actorIds.erase(lordId)
	if actorIds.size() < 3:
		var msg = "{0}人才不足，无以定品".format([city.get_full_name()])
		play_dialog(actorId, msg, 3, 2999)
		return
	var msg = "贤有识见者，难免埋没\n主公不得不用心分别擢用\n（将花费 {0} 金".format([
		GOLD_COST
	])
	play_dialog(actorId, msg, 2, 2000)
	return

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_10107_2():
	var selected = ske.affair_get_skill_val_int_array()
	if selected.size() >= 3:
		goto_step("3")
		return
	var list = SceneManager.actorlist
	print(list)
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var lordId = city.get_lord_id()
	var actorIds = city.get_actor_ids()
	actorIds.erase(lordId)
	for actorId in selected:
		actorIds.erase(actorId)
	var types = ["上上", "上中", "上下"]
	var msg = "请选择「{0}」品级武将".format([types[selected.size()]])
	SceneManager.show_actorlist_army(actorIds, false, msg, false)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001():
	if not wait_for_choose_actor("player_ready", false, true):
		return
	var lst = SceneManager.actorlist
	var targetId = lst.get_select_actor()
	if targetId >= 0:
		var selected = ske.affair_get_skill_val_int_array()
		selected.erase(targetId)
		selected.append(targetId)
		ske.affair_set_skill_val(selected, 1)
		goto_step("2")
	return

func effect_10107_3():
	var selected = ske.affair_get_skill_val_int_array()
	if selected.size() < 3:
		goto_step("end")
		return

	var msg = "{0}忠恪匪躬\n{1}信义可复\n{2}学以为己\n皆上士之选也".format([
		DataManager.get_actor_honored_title(selected[0], actorId),
		DataManager.get_actor_honored_title(selected[1], actorId),
		DataManager.get_actor_honored_title(selected[2], actorId),
	])
	play_dialog(actorId, msg, 1, 2002)
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_10107_4():
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)

	var selected = ske.affair_get_skill_val_int_array()
	if selected.size() < 3:
		goto_step("end")
		return

	var actors = []
	for actorId in selected:
		actors.append(ActorHelper.actor(actorId))

	ske.affair_cd(12)
	city.add_gold(-GOLD_COST)
	var msg = "【{0}】期间：".format([ske.skill_name])
	for i in 3:
		# 用 actor 数据和光环配合，以加速判断
		# 否则所有武将每次都要判断光环，不合理的代价
		# actor 数据触发光环判断，并存储细节
		# 最终生效与否，以光环为准
		actors[i]._set_attr("定品", i + 1)
		var srb = SkillRangeBuff.new()
		srb.actorId = actorId
		srb.skillName = ske.skill_name
		srb.effectType = "光环"
		srb.sceneId = 10000
		srb.effectId = ske.effect_Id
		srb.triggerId = -1
		srb.effectTag = "定品"
		srb.effectTagVal = 12
		srb.targetType = SkillRangeBuff.BuffTargetType.ACTOR
		srb.targetId = selected[i]
		srb.condition = ""
		srb.continuous = 1
		DataManager.skill_range_buff.append(srb)
		msg += "\n{0}士兵上限为{1}".format([
			actors[i].get_name(), DataManager.get_actor_max_soldiers(actors[i].actorId)
		])
	play_dialog(-1, msg, 1, 2999)
	return

func effect_10107_end():
	skill_end_clear()
	FlowManager.add_flow("player_ready")
	return
