extends "effect_10000.gd"

# 讨州主动技
#【讨州】内政，主动技。指定一个与你方相邻的其他（池数＞2）势力的城池为目标。对方可选择将该城让于你方：若选择“是”，该技能于游戏中不可再发动；否则，令一年内的目标城目标势力的战争发生时，目标势力所有主将自动附加<自矜>，该效果冷却一年。

const EFFECT_ID = 10135
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_10135_start() -> void:
	var city = clCity.city(DataManager.player_choose_city)
	var choices = []
	for targetCityId in city.get_connected_city_ids([], [-1, city.get_vstate_id()]):
		var targetCity = clCity.city(targetCityId)
		if clCity.all_cities([targetCity.get_vstate_id()]).size() < 2:
			continue
		if targetCity.get_lord_id() == targetCity.get_leader_id():
			# 不能讨要都城
			continue
		choices.append(targetCityId)
	
	if choices.empty():
		var msg = "没有合适的目标城池\n不可发动【{0}】".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return

	SceneManager.hide_all_tool()
	SceneManager.clear_bottom()
	SceneManager.current_scene().cursor.show()
	SceneManager.current_scene().set_city_cursor_position(choices[0])
	var msg = "请选择目标城市"
	SceneManager.show_unconfirm_dialog(msg)
	LoadControl.set_view_model(2000)
	ske.affair_set_skill_val(choices, 1)
	DataManager.twinkle_citys = choices
	return

func on_view_model_2000_delta(delta:float) -> void:
	var city = clCity.city(DataManager.player_choose_city)
	var pointedCityId = SceneManager.current_scene().get_curosr_point_city()
	if pointedCityId < 0:
		SceneManager.show_cityInfo(false)
	else:
		SceneManager.show_cityInfo(true, pointedCityId, 0)
	var choices = ske.affair_get_skill_val_int_array()
	var cityId = wait_for_choose_city(delta, "player_ready", choices)
	if cityId < 0:
		return
	if not cityId in choices:
		SceneManager.show_unconfirm_dialog("此非可选目标城池")
		return
	DataManager.set_env("目标", cityId)
	goto_step("selected")
	return

func effect_10135_selected() -> void:
	var city = clCity.city(DataManager.player_choose_city)
	var targetCityId = DataManager.get_env_int("目标")
	var targetCity = clCity.city(targetCityId)

	var msg = "向{0}军发起【{1}】\n令其让出{2}\n可否？".format([
		targetCity.get_lord_name(), ske.skill_name,
		targetCity.get_full_name(),
	])
	play_dialog(actorId, msg, 2, 2001, true)
	DataManager.twinkle_citys = [city.ID, targetCity.ID]
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_10135_confirmed() -> void:
	var city = clCity.city(DataManager.player_choose_city)
	var targetCityId = DataManager.get_env_int("目标")
	var targetCity = clCity.city(targetCityId)

	var msg = "久违音问，{0}安好？".format([
		DataManager.get_actor_honored_title(targetCity.get_leader_id(), actorId),
	])
	play_dialog(actorId, msg, 1, 2002)
	DataManager.twinkle_citys = [city.ID]
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_what")
	return

func effect_10135_what() -> void:
	var city = clCity.city(DataManager.player_choose_city)
	var targetCityId = DataManager.get_env_int("目标")
	var targetCity = clCity.city(targetCityId)

	var msg = "{0}来必有意，还请直言".format([
		DataManager.get_actor_honored_title(actorId, targetCity.get_leader_id()),
	])
	play_dialog(targetCity.get_leader_id(), msg, 2, 2003)
	DataManager.twinkle_citys = [targetCity.ID]
	return

func on_view_model_2003() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_ask")
	return

func effect_10135_ask() -> void:
	var city = clCity.city(DataManager.player_choose_city)
	var targetCityId = DataManager.get_env_int("目标")
	var targetCity = clCity.city(targetCityId)

	var memo = "吾主"
	if actor.get_loyalty() == 100:
		memo = "吾军"
	var msg = "{0}分野，{1}故地也\n前望相让，{2}亦允可\n望行方便，以全两家之好".format([
		targetCity.get_full_name(), memo,
		DataManager.get_actor_honored_title(targetCity.get_lord_id(), actorId),
	])
	play_dialog(actorId, msg, 2, 2004)
	DataManager.twinkle_citys = [city.ID]
	return

func on_view_model_2004() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_decision")
	return

func effect_10135_decision() -> void:
	var city = clCity.city(DataManager.player_choose_city)
	var targetCityId = DataManager.get_env_int("目标")
	var targetCity = clCity.city(targetCityId)

	var diff = city.get_lord().get_moral() - targetCity.get_lord().get_moral()
	var chance = 0
	if diff > 10:
		chance = 30
	elif diff > 5:
		chance = 10
	var distance = actor.personality_distance(targetCity.get_leader())
	if distance > 35:
		chance = 0
	elif distance > 10:
		chance -= 20
	elif distance == 5:
		chance += 10

	if Global.get_rate_result(chance):
		goto_step("ok")
		return
	
	goto_step("gun")
	return

func effect_10135_ok() -> void:
	var city = clCity.city(DataManager.player_choose_city)
	var targetCityId = DataManager.get_env_int("目标")
	var targetCity = clCity.city(targetCityId)

	var msg = "…… \n既有前言，吾不废大计\n惟愿{0}记得今日".format([
		DataManager.get_actor_honored_title(city.get_lord_id(), targetCity.get_leader_id()),
	])
	play_dialog(targetCity.get_leader_id(), msg, 2, 2005)
	DataManager.twinkle_citys = [targetCity.ID]
	return

func on_view_model_2005() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_move")
	return

func effect_10135_move() -> void:
	var city = clCity.city(DataManager.player_choose_city)
	var targetCityId = DataManager.get_env_int("目标")
	var targetCity = clCity.city(targetCityId)

	ske.affair_cd(99999)
	# 简单处理，都移动到首都，并且不考虑连线
	var capital = clCity.get_capital_city(targetCity.get_vstate_id())
	for memberId in targetCity.get_actor_ids():
		clCity.move_to(memberId, capital.ID)
	targetCity.set_vstate_id(-1)

	var msg = "幸不辱命！\n{0}军已让出{1}\n可速点将接收".format([
		capital.get_lord_name(), targetCity.get_full_name(),
	])
	DataManager.set_env("目标", capital.ID)
	play_dialog(actorId, msg, 1, 2006)
	DataManager.twinkle_citys = [city.ID, targetCity.ID]
	return

func on_view_model_2006() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_done")
	return

func effect_10135_done() -> void:
	var city = clCity.city(DataManager.player_choose_city)
	var targetCityId = DataManager.get_env_int("目标")
	var targetCity = clCity.city(targetCityId)

	var vs = city.vstate()
	var tv = targetCity.vstate()
	var prevMemo = tv.get_relation_index_memo(vs.id)
	tv.relation_index_change(vs.id, 10)
	vs.relation_index_change(tv.id, 10)
	var memo = tv.get_relation_index_memo(vs.id)
	var msg = "两家关系有所改善"
	if memo != prevMemo:
		msg += "\n{0}对我军的态度变为：{1}"
	else:
		msg += "\n{0}对我军的态度现为：{1}"
	msg = msg.format([tv.get_lord_name(), memo])
	play_dialog(actorId, msg, 1, 2999)
	DataManager.twinkle_citys = clCity.all_city_ids([city.get_vstate_id(), targetCity.get_vstate_id()])
	return

func effect_10135_gun() -> void:
	var city = clCity.city(DataManager.player_choose_city)
	var targetCityId = DataManager.get_env_int("目标")
	var targetCity = clCity.city(targetCityId)

	var msg = "普天之下，莫非汉土\n吾主以{0}相托\n岂有以一言相让之理？".format([
		targetCity.get_full_name(),
		DataManager.get_actor_honored_title(actorId, targetCity.get_leader_id()),
	])
	play_dialog(targetCity.get_leader_id(), msg, 0, 2007)
	DataManager.twinkle_citys = [targetCity.ID]
	return

func on_view_model_2007() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_rejected")
	return

func effect_10135_rejected() -> void:
	var city = clCity.city(DataManager.player_choose_city)
	var targetCityId = DataManager.get_env_int("目标")
	var targetCity = clCity.city(targetCityId)

	var msg = "此等妄语，吾不欲闻\n欲得{0}，可问我刀\n{1}勿复言，请回！".format([
		targetCity.get_full_name(),
		DataManager.get_actor_honored_title(actorId, targetCity.get_leader_id()),
	])
	play_dialog(targetCity.get_leader_id(), msg, 0, 2008)
	DataManager.twinkle_citys = [targetCity.ID]
	return

func on_view_model_2008() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_failed")
	return

func effect_10135_failed() -> void:
	var city = clCity.city(DataManager.player_choose_city)
	var targetCityId = DataManager.get_env_int("目标")
	var targetCity = clCity.city(targetCityId)

	ske.affair_cd(12)
	var srb = SkillRangeBuff.new()
	srb.actorId = actorId
	srb.skillName = ske.skill_name
	srb.effectType = "光环"
	srb.sceneId = 10000
	srb.effectId = ske.effect_Id
	srb.triggerId = -1
	srb.effectTag = "主将自矜"
	srb.effectTagVal = 12
	srb.targetType = SkillRangeBuff.BuffTargetType.VSTATE
	srb.targetId = targetCity.get_vstate_id()
	srb.condition = ""
	srb.continuous = 1
	DataManager.skill_range_buff.append(srb)
	var msg = "{0}如此无礼！\n骄兵必败，当择机图之\n（{1}军一年内附加 [自矜]".format([
		DataManager.get_actor_naughty_title(targetCity.get_leader_id(), actorId),
		targetCity.get_lord_name(),
	])
	play_dialog(actorId, msg, 0, 2009)
	DataManager.twinkle_citys = [city.ID]
	return

func on_view_model_2009() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_end")
	return

func effect_10135_end() -> void:
	var city = clCity.city(DataManager.player_choose_city)
	var targetCityId = DataManager.get_env_int("目标")
	var targetCity = clCity.city(targetCityId)

	var vs = city.vstate()
	var tv = targetCity.vstate()
	var prevMemo = tv.get_relation_index_memo(vs.id)
	tv.relation_index_change(vs.id, -20)
	vs.relation_index_change(tv.id, -20)
	var memo = tv.get_relation_index_memo(vs.id)
	var msg = "两家关系有所恶化"
	if memo != prevMemo:
		msg += "\n{0}对我军的态度变为：{1}"
	else:
		msg += "\n{0}对我军的态度现为：{1}"
	msg = msg.format([tv.get_lord_name(), memo])
	play_dialog(actorId, msg, 3, 2999)
	DataManager.twinkle_citys = clCity.all_city_ids([city.get_vstate_id(), targetCity.get_vstate_id()])
	return
