extends "effect_10000.gd"

#陈势主动技
#【陈势】内政，主动技。指定1个相邻且只有1城的势力发动。向目标势力陈述厉害，提议投降给本势力。若目标君主同意：其势力灭亡，所有城归属给本势力，原君主变为忠90的将领；若其不同意，本月下一次对目标势力城发起攻击时，不消耗命令书。每3月限1次。[投降概率（玩家不可见）=双方城差数%，且至多为15%]

const EFFECT_ID = 10080
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const DIALOGS = [
	[1, "<FROM>此来，所为何事？", 2],
	[0, "<TARGET>身处危殆而不自知\n特为足下解难而来", 2],
	[0, "我主广布恩德，仁胜矣\n我军所向披靡，勇胜矣\n方今<CITY>孤悬，势胜矣", 2],
	[0, "群雄环伺，如何独善？\n不若以<CITY>归于我主\n徒丧于乱，何如让贤之德？", 2],
	["flow", FLOW_BASE + "_4"]
]
var dialogs = DIALOGS.duplicate(true)
var dialogProcess = -1

func effect_10080_start():
	var city = clCity.city(DataManager.player_choose_city)
	var targets = get_target_city_ids(city.ID)
	if targets.empty():
		var msg = "目前并无可发动【{0}】的目标".format([ske.skill_name])
		SceneManager.show_confirm_dialog(msg, actorId, 3)
		LoadControl.set_view_model(2999)
		return

	SceneManager.hide_all_tool()
	SceneManager.clear_bottom()
	DataManager.twinkle_citys.clear()
	SceneManager.current_scene().cursor.show()
	SceneManager.current_scene().set_city_cursor_position(DataManager.player_choose_city)
	SceneManager.show_unconfirm_dialog("请选择目标城市")
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000_delta(delta:float):
	var city = clCity.city(DataManager.player_choose_city)
	var targets = get_target_city_ids(city.ID)
	DataManager.twinkle_citys = targets
	DataManager.twinkle_citys.append(city.ID)
	var cityId = wait_for_choose_city(delta, "player_ready", targets)
	if cityId < 0:
		return
	if clCity.city(cityId).get_vstate_id() == city.get_vstate_id():
		SceneManager.show_unconfirm_dialog("此为自势力城市")
		return
	if not cityId in targets:
		SceneManager.show_unconfirm_dialog("请选择可发动的目标城市")
		return
	DataManager.set_env("目标", cityId)
	goto_step("2")
	return

func effect_10080_2():
	var targetCityId = DataManager.get_env_int("目标")
	var msg = "{0}势孤力弱\n愿陈说厉害，令其部归降\n可否？".format([
		clCity.city(targetCityId).get_leader_name(),
	])
	SceneManager.show_yn_dialog(msg, actorId, 2)
	LoadControl.set_view_model(2001)
	return


func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3", "player_ready")
	return

func effect_10080_3():
	ske.affair_cd(3)
	var targetCityId = DataManager.get_env_int("目标")
	var targetCity = clCity.city(targetCityId)
	var leaderId = targetCity.get_leader_id()
	for dialogInfo in dialogs:
		match dialogInfo[0]:
			0:
				dialogInfo[0] = actorId
			1:
				dialogInfo[0] = leaderId
		dialogInfo[1] = dialogInfo[1].replace("<FROM>", DataManager.get_actor_honored_title(actorId, leaderId))
		dialogInfo[1] = dialogInfo[1].replace("<TARGET>", DataManager.get_actor_honored_title(leaderId, actorId))
		dialogInfo[1] = dialogInfo[1].replace("<CITY>", targetCity.get_full_name())
	dialogProcess = 0
	SceneManager.hide_all_tool()
	LoadControl.set_view_model(2002)
	return

func on_view_model_2002():
	if dialogProcess < 0:
		return
	if dialogProcess >= dialogs.size():
		LoadControl.set_view_model(2004)
		return
	var dialogInfo = dialogs[dialogProcess]
	if str(dialogInfo[0]) == "flow":
		FlowManager.add_flow(dialogInfo[1])
		LoadControl.set_view_model(2004)
		return
	SceneManager.show_confirm_dialog(dialogInfo[1], dialogInfo[0], dialogInfo[2])
	LoadControl.set_view_model(2003)
	return

func on_view_model_2003():
	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	dialogProcess += 1
	LoadControl.set_view_model(2002)
	return

func effect_10080_4():
	var city = clCity.city(DataManager.player_choose_city)
	var targetCityId = DataManager.get_env_int("目标")
	var targetCity = clCity.city(targetCityId)
	var fromCount = clCity.all_cities([city.get_vstate_id()]).size()
	var targetCount = clCity.all_cities([targetCity.get_vstate_id()]).size()
	var rate = min(15, fromCount - targetCount)
	if rate <= 0 or not Global.get_rate_result(rate):
		# 城市 id + 1 以与 0 区分
		ske.affair_set_skill_val(targetCityId + 1, 1)
		goto_step("5")
		return

	var leaderId = targetCity.get_leader_id()
	var msg = "{0}此言，不无道理\n愿献{1}，率众归顺".format([
		DataManager.get_actor_honored_title(actorId, leaderId),
		targetCity.get_full_name()
	])
	var vs = clVState.vstate(targetCity.get_vstate_id())
	vs.set_perished()
	for targetId in targetCity.get_actor_ids():
		var targetActor = ActorHelper.actor(targetId)
		if targetActor.get_loyalty() == 100:
			targetActor.set_loyalty(90)
	targetCity.change_vstate(city.get_vstate_id())
	SceneManager.show_confirm_dialog(msg, leaderId, 3)
	LoadControl.set_view_model(2999)
	return

func effect_10080_5():
	var city = clCity.city(DataManager.player_choose_city)
	var targetCityId = DataManager.get_env_int("目标")
	var targetCity = clCity.city(targetCityId)
	var leaderId = targetCity.get_leader_id()
	var msg = "{0}美意，在下心领\n岂不闻，势危不堕英雄志\n吾在一日，🆚必保{1}不失".format([
		DataManager.get_actor_honored_title(actorId, leaderId),
		targetCity.get_full_name()
	])
	SceneManager.show_confirm_dialog(msg, leaderId, 0)
	LoadControl.set_view_model(2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation("player_ready")
	return

func get_target_city_ids(cityId:int)->PoolIntArray:
	var city = clCity.city(cityId)
	var connected = city.get_connected_city_ids([], [-1, city.get_vstate_id()])
	var targets = []
	for targetId in connected:
		var targetCity = clCity.city(targetId)
		var targetVstateId = targetCity.get_vstate_id()
		if clCity.all_cities([targetVstateId]).size() > 1:
			# 不是孤零零
			continue
		targets.append(targetId)
	targets.sort()
	return targets
