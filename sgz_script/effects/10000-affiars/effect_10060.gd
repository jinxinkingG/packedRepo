extends "effect_10000.gd"

#集盟主动技
#【集盟】内政，君主主动技。你可指定1个其他势力为目标发动。除目标之外的所有势力，成立同盟12月。游戏中限用1次。

const EFFECT_ID = 10060
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const DIALOGS = [
	"{0}老贼倡乱，恨不能食肉寝皮，{1}愿往",
	"如此盛举，岂能无我{1}",
	"早有此意，既{2}首倡，诸侯纷纷响应，当会盟共击{0}",
]

func on_view_model_2000_delta(delta:float):
	var currentCityId = get_working_city_id()
	var currentCity = clCity.city(currentCityId)
	var quickChoices = []
	for city in clCity.all_cities():
		if city.get_vstate_id() != currentCity.get_vstate_id():
			continue
		for cid in city.get_connected_city_ids():
			if cid in quickChoices:
				continue
			if clCity.city(cid).get_vstate_id() in [-1, currentCity.get_vstate_id()]:
				continue
			quickChoices.append(cid)
	var cityId = wait_for_choose_city(delta, "player_ready", quickChoices)
	if cityId < 0:
		return
	var city = clCity.city(cityId)
	if city.get_vstate_id() in [-1, currentCity.get_vstate_id()]:
		SceneManager.show_unconfirm_dialog("请选择敌对势力")
		return
	set_env("目标", cityId)
	FlowManager.add_flow(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3", "player_ready")
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func on_view_model_3000_delta(delta:float):
	var accumulated = DataManager.get_env_float("delta")
	DataManager.set_env("delta", accumulated + delta)
	if accumulated >= 2.0 * Engine.time_scale:
		LoadControl.set_view_model(-1)
		SceneManager.dialog_msg_complete(true)
		goto_step("AI_2")
		return
	wait_for_skill_result_confirmation(FLOW_BASE + "_AI_2")
	return

func on_view_model_3001_delta(delta:float):
	var accumulated = DataManager.get_env_float("delta")
	DataManager.set_env("delta", accumulated + delta)
	if accumulated >= 2.0 * Engine.time_scale:
		LoadControl.set_view_model(-1)
		SceneManager.dialog_msg_complete(true)
		goto_step("AI_3")
		return
	wait_for_skill_result_confirmation(FLOW_BASE + "_AI_3")
	return

func check_AI_perform()->bool:
	# 不论有多少个集盟，所有 AI 只发动一次
	if get_env_int("AI.集盟发动") > 0:
		return false
	if get_env_int("AI.毒杀少帝") < 0:
		return false
	set_env("AI.集盟发动", 1)
	return true

func effect_10060_AI_start():
	var targetVstateId = get_env_int("AI.毒杀少帝")
	var targetLordId = clVState.vstate(targetVstateId).get_lord_id()
	var msg = "{0}匹夫，暴虐不仁，祸乱天下，岂能不讨？四海之间，义士安在？当与共之！".format([
		ActorHelper.actor(targetLordId).get_name(),
	])
	set_env("AI.集盟.PROGRESS", 0)
	SoundManager.play_anim_bgm("res://resource/sounds/se/AI_War.ogg")
	SceneManager.show_confirm_dialog(msg, actorId, 0)
	DataManager.set_env("delta", 0)
	LoadControl.set_view_model(3000)
	return

func effect_10060_AI_2():
	var targetVstateId = get_env_int("AI.毒杀少帝")
	var targetLordId = clVState.vstate(targetVstateId).get_lord_id()
	var progress = get_env_int("AI.集盟.PROGRESS")
	var attendlordIds = []
	for vs in clVState.all_vstates():
		if not vs.is_alive():
			continue
		if vs.get_lord_id() in [actorId, targetLordId]:
			continue
		attendlordIds.append(vs.get_lord_id())
	attendlordIds.shuffle()
	if progress < 0 or progress >= DIALOGS.size():
		var names = [actor.get_name()]
		for lordId in attendlordIds:
			names.append(ActorHelper.actor(lordId).get_name())
			if names.size() >= 3:
				names[names.size() - 1] += "等{0}路诸侯".format([attendlordIds.size()])
				break
		var msg = "公元 {0} 年 {1} 月\n{2}会盟，共讨{3}".format([
			DataManager.year, DataManager.month,
			"、".join(names),
			ActorHelper.actor(targetLordId).get_name(),
		])
		SceneManager.show_confirm_dialog(msg, -1)
		SceneManager.play_affiars_animation("Town_Save", "", true)
		DataManager.set_env("delta", 0)
		LoadControl.set_view_model(3001)
		return
	var msg = DIALOGS[progress].format([
		ActorHelper.actor(targetLordId).get_name(),
		DataManager.get_actor_self_title(attendlordIds[0]),
		actor.get_name(),
	])
	set_env("AI.集盟.PROGRESS", progress + 1)
	SceneManager.show_confirm_dialog(msg, attendlordIds[0], 0)
	DataManager.set_env("delta", 0)
	LoadControl.set_view_model(3000)
	return

func effect_10060_AI_3():
	var targetVstateId = get_env_int("AI.毒杀少帝")	
	perform_skill(targetVstateId)
	FlowManager.add_flow("AI_active_skill")
	return

func effect_10060_start():
	SceneManager.hide_all_tool()
	SceneManager.clear_bottom()
	DataManager.twinkle_citys.clear()
	SceneManager.current_scene().cursor.show()
	SceneManager.current_scene().set_city_cursor_position(get_working_city_id())
	SceneManager.show_unconfirm_dialog("请选择目标势力")
	LoadControl.set_view_model(2000)
	return

func effect_10060_2():
	var targetCityId = get_env_int("目标")
	var targetVstateId = clCity.city(targetCityId).get_vstate_id()
	var targetLordId = clVState.vstate(targetVstateId).get_lord_id()
	var msg = "{0}匹夫，暴虐不仁，祸乱天下，岂能不讨？四海之间，义士安在？当与共之！".format([
		ActorHelper.actor(targetLordId).get_name(),
	])
	set_env("集盟.PROGRESS", 0)
	SoundManager.play_anim_bgm("res://resource/sounds/se/AI_War.ogg")
	SceneManager.show_yn_dialog(msg, actorId, 0)
	LoadControl.set_view_model(2001)
	return

func effect_10060_3():
	var targetCityId = get_env_int("目标")
	var targetVstateId = clCity.city(targetCityId).get_vstate_id()
	var targetLordId = clVState.vstate(targetVstateId).get_lord_id()
	var progress = get_env_int("集盟.PROGRESS")
	var attendlordIds = []
	for vs in clVState.all_vstates():
		if not vs.is_alive():
			continue
		if vs.get_lord_id() in [actorId, targetLordId]:
			continue
		attendlordIds.append(vs.get_lord_id())
	attendlordIds.shuffle()
	if progress < 0 or progress >= DIALOGS.size():
		var names = [actor.get_name()]
		for lordId in attendlordIds:
			names.append(ActorHelper.actor(lordId).get_name())
			if names.size() >= 3:
				names[names.size() - 1] += "等{0}路诸侯".format([attendlordIds.size()])
				break
		var msg = "公元 {0} 年 {1} 月\n{2}会盟，共讨{3}".format([
			DataManager.year, DataManager.month,
			"、".join(names),
			ActorHelper.actor(targetLordId).get_name(),
		])
		SceneManager.show_confirm_dialog(msg, -1)
		SceneManager.play_affiars_animation("Town_Save", "", true)
		LoadControl.set_view_model(2002)
		return
	var msg = DIALOGS[progress].format([
		ActorHelper.actor(targetLordId).get_name(),
		DataManager.get_actor_self_title(attendlordIds[0]),
		actor.get_name(),
	])
	set_env("集盟.PROGRESS", progress + 1)
	SceneManager.show_confirm_dialog(msg, attendlordIds[0], 0)
	LoadControl.set_view_model(2001)
	return

func effect_10060_4():
	var targetCityId = get_env_int("目标")
	var targetVstateId = clCity.city(targetCityId).get_vstate_id()
	var targetLordId = clVState.vstate(targetVstateId).get_lord_id()
	
	perform_skill(targetVstateId)
	FlowManager.add_flow("player_ready")
	return

func perform_skill(targetVstateId:int)->void:
	var otherVstateIds = []
	for vs in clVState.all_vstates():
		if not vs.is_alive():
			continue
		if vs.id == targetVstateId:
			continue
		otherVstateIds.append(vs.id)
		clVState.set_alliance(targetVstateId, vs.id, 0)
	for a in otherVstateIds:
		for b in otherVstateIds:
			if a == b:
				continue
			clVState.set_alliance(a, b, 12)
	ske.affair_cd(99999)
	return
