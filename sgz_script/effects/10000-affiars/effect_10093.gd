extends "effect_10000.gd"

#融通主动技
#【融通】内政，主动技。势力所有城池不再于4月集中收税，而是每月收获 1/10 的税赋（最高不超过 999）。选定后，持续一年后，自动解除效果，每年限1次。

const EFFECT_ID = 10093
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_10093_start():
	var cityId = get_working_city_id()
	if cityId < 0:
		skill_end_clear()
		FlowManager.add_flow("player_ready")
		return
	var city = clCity.city(cityId)
	var vs = clVState.vstate(city.get_vstate_id())
	var msg = "革新币制，加速流通\n将每月获得 1/10 税赋收入\n可否？"
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

func effect_10093_2():
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var vs = clVState.vstate(city.get_vstate_id())

	# 找政高的捧哏
	var speaker = DataManager.get_max_property_actorId("政", vs.id, [actorId])
	if speaker == -1:
		goto_step("3")
		return
	var msg = "{0}之策甚善\n运筹帷幄\n吾不如{0}远矣".format([
		DataManager.get_actor_honored_title(actorId, speaker)
	])
	play_dialog(speaker, msg, 1, 2001)
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_10093_3():
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var vs = clVState.vstate(city.get_vstate_id())

	var lord = ActorHelper.actor(vs.get_lord_id())
	if lord.actorId == actorId:
		goto_step("4")
		return

	var msg = "{0}真吾之萧何也\n当速行之\n数月之间，何愁府库不实？".format([
		DataManager.get_actor_honored_title(actorId, lord.actorId)
	])
	play_dialog(lord.actorId, msg, 1, 2002)
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_10093_4():
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var vs = clVState.vstate(city.get_vstate_id())

	ske.affair_cd(12)

	var srb = SkillRangeBuff.new()
	srb.actorId = actorId
	srb.skillName = ske.skill_name
	srb.effectType = "光环"
	srb.sceneId = 10000
	srb.effectId = ske.effect_Id
	srb.triggerId = -1
	srb.effectTag = "每月赋税"
	srb.effectTagVal = 12
	srb.targetType = SkillRangeBuff.BuffTargetType.VSTATE
	srb.targetId = vs.id
	srb.condition = ""
	srb.continuous = 1
	DataManager.skill_range_buff.append(srb)

	var fromYear = DataManager.year
	var fromMonth = DataManager.month + 1
	if fromMonth == 13:
		fromYear += 1
		fromMonth = 1
	var toYear = DataManager.year + 1
	var toMonth = DataManager.month
	var msg = "【{0}】发动\n{1}年{2}月 ~ {3}年{4}月间\n将每月获得1/10赋税".format([
		ske.skill_name,
		fromYear, fromMonth, toYear, toMonth,
	])
	play_dialog(-1, msg, 1, 2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return

