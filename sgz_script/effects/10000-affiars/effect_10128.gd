extends "effect_10000.gd"

# 义襄主动技
#【义襄】内政，太守主动技。你可邀请在野或流浪武将参与城市建设或搜索。若本城有在野或流浪武将，必定成功；否则，其他在野或流浪武将有概率响应。每月限1次。

const EFFECT_ID = 10128
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_10128_start() -> void:
	var city = clCity.city(DataManager.player_choose_city)
	var msg = "{0}民生疲敝，百废待兴\n乱世当生英杰，张榜求贤\n可有义士襄助？".format([
		city.get_full_name(),
	])
	ske.affair_cd(1)
	play_dialog(actorId, msg, 2, 2000)
	DataManager.twinkle_citys = [city.ID]
	DataManager.cityInfo_type = 1
	SceneManager.show_cityInfo(true)
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_response")
	return

func effect_10128_response() -> void:
	var city = clCity.city(DataManager.player_choose_city)
	var unofficed = clCity.get_unoffice_actors(city.ID)
	var rate = 100 - actor.get_moral()
	rate = max(10, rate)
	rate = min(50, rate)
	if unofficed.empty() and Global.get_rate_result(rate):
		# 本城无在野，且运气不好
		goto_step("badluck")
		return

	var volunteer = null
	if not unofficed.empty():
		unofficed.shuffle()
		volunteer = ActorHelper.actor(unofficed[0])
	else:
		var candidates = ActorHelper.all_unofficed_actors()
		if candidates.empty():
			candidates = ActorHelper.all_exiled_actors()
		if candidates.empty() and DataManager.is_stars_drama():
			# 星耀特殊逻辑，这里与星耀出仕的范围保持一致
			candidates = ActorHelper.all_disabled_actors([StaticManager.ACTOR_ID_DIY, StaticManager.ACTOR_ID_LIUBIAN])
		if candidates.empty():
			# 实在没人了
			goto_step("nobody")
			return
		candidates.shuffle()
		volunteer = candidates[0]
	ske.affair_set_skill_val(volunteer.actorId, 1)
	var type = ""
	var action = ""
	if volunteer.get_politics() < 80 and Global.get_rate_result(50):
		# 政不足，有概率直接搜索
		goto_step("search")
		return

	if city.get_defence() < 99:
		# 优先防灾
		type = "防灾"
		action = "防灾工程"
	elif city.get_eco() < city.get_land():
		# 产业小于土地，肯定也没满
		type = "产业"
		action = "产业开发"
	elif city.get_land() < 999:
		# 土地未满
		type = "土地"
		action = "土地开发"
	elif city.get_pop() < 50000:
		type = "人口"
		action = "人口开发"
	else:
		# 转搜索分支
		goto_step("search")
		return

	var prevCmd = DataManager.get_current_develop_command()
	var cmd = DataManager.new_develop_command(type, volunteer.actorId, DataManager.player_choose_city)
	cmd.cost = 0
	cmd.lastActionId = prevCmd.lastActionId
	cmd.costRate = 0
	cmd.decide_cost()

	var developSetting = StaticManager.get_develop_setting()
	var develop_gif_groups = developSetting["develop_gif_groups"]
	var develop_ask_dialog = developSetting["develop_ask_dialog"]
	var animation_name = developSetting["animation_name"]
	var anim = "Town_Develop_Farm_00"
	if cmd.type != "防灾":
		var dialogId = develop_gif_groups[cmd.type][cmd.devLevel][cmd.devRnd]
		while dialogId == -1:
			var r = Global.get_random(0, 4)
			dialogId = develop_gif_groups[cmd.type][cmd.devLevel][r]
		anim = animation_name[cmd.type][dialogId]

	var msg = "{0}爱民\n{1}别无所长，愿效一臂之力\n（{2}助力{3}".format([
		DataManager.get_actor_honored_title(actorId, volunteer.actorId),
		volunteer.get_short_name(), volunteer.get_name(), action,
	])
	cmd.execute()
	var msgs = cmd.get_result_messages()
	DataManager.set_env("内政.对话PENDING", msgs)

	SceneManager.play_affiars_animation(
		anim, "", false,
		msg, cmd.actionId, 1)
	LoadControl.set_view_model(2001)
	return

func effect_10128_badluck() -> void:
	var msg = "竟无响应 ……\n是吾德薄故也"
	play_dialog(actorId, msg, 3, 2999)
	return

func effect_10128_nobody() -> void:
	var msg = "竟无响应 ……\n是野无遗贤也"
	play_dialog(actorId, msg, 3, 2999)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_dev_result")
	return

func effect_10128_dev_result() -> void:
	var msgs = DataManager.get_env_array("内政.对话PENDING")
	if msgs.empty():
		skill_end_clear()
		FlowManager.add_flow("player_ready")
		return
	if msgs.size() > 3:
		DataManager.set_env("内政.对话PENDING", msgs.slice(3, msgs.size() - 1))
		msgs = msgs.slice(0, 2)
	else:
		DataManager.set_env("内政.对话PENDING", [])
	SceneManager.show_confirm_dialog("\n".join(msgs), actorId, 1)
	SceneManager.dialog_msg_complete(true)
	DataManager.cityInfo_type = 1
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(2001)
	return

func effect_10128_search() -> void:
	var volunteer = ActorHelper.actor(ske.affair_get_skill_val_int())
	var city = clCity.city(DataManager.player_choose_city)
	var cmd = DataManager.new_search_command(city.ID, volunteer.actorId)
	var msg = "{0}爱民\n{1}别无所长，愿效一臂之力\n（{2}助力搜索乡野".format([
		DataManager.get_actor_honored_title(actorId, volunteer.actorId),
		volunteer.get_short_name(), volunteer.get_name()
	])
	var result = cmd.decide_result()
	while not result in [1, 2, 3, 4]:
		# 聚焦结果为搜索资源
		result = cmd.decide_result()
	cmd.execute()
	SceneManager.play_affiars_animation("Town_Search", "", false, msg, cmd.fromId)
	LoadControl.set_view_model(2002)
	return

func effect_10128_search_report() -> void:
	var cmd = DataManager.get_current_search_command()
	var d = cmd.next_dialog()
	if d == null:
		skill_end_clear()
		FlowManager.add_flow("player_ready")
		return
	play_dialog(d.actorId, d.msg, d.mood, 2002)
	DataManager.cityInfo_type = 3
	SceneManager.show_cityInfo(true)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_search_report")
	return
