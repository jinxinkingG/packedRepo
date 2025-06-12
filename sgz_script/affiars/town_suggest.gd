extends "affairs_base.gd"

#建言
func _init() -> void:
	LoadControl.view_model_name = "内政-玩家-步骤";

	FlowManager.bind_import_flow("suggestion_start",self)
	FlowManager.bind_import_flow("suggestion_2",self)
	FlowManager.bind_import_flow("suggestion_3",self)
	FlowManager.bind_import_flow("suggestion_4",self)
	FlowManager.bind_import_flow("suggestion_done",self)

	return

#按键操控
func _input_key(delta: float):
	match LoadControl.get_view_model():
		261:
			wait_for_confirmation("suggestion_2")
		262:
			wait_for_yesno("suggestion_4", "suggestion_start")
		263:
			wait_for_confirmation("suggestion_start")
	return

#---------------建言-------------------
func suggestion_start():
	SceneManager.current_scene().cursor.hide()
	if DataManager.get_env_int("内政.建言开关", 1) <= 0:
		FlowManager.add_flow("suggestion_done")
		return
	DataManager.set_env("内政.建言", [])
	var fromCity = clCity.city(DataManager.player_choose_city)
	var vstateId = fromCity.get_vstate_id()
	var bestPolitician = -1
	var largestPol = -1
	var lowManagement = []
	var lowDefence = []
	var assignmentRequired = []
	var leastDeveloped = []
	var leastDevProgress = 999999
	var learningRequired = []
	var lowLoyalty = []
	var toPersuade = []
	# 为了过论。。。
	var fengchu = []
	for city in clCity.all_cities([vstateId]):
		if city.is_delegated():
			continue
		var totalSoldiers:int = 0
		var maxSoldiers:int = 0
		var i = 0
		for actorId in city.get_actor_ids():
			var actor = ActorHelper.actor(actorId)
			if DataManager.month == 12 and "过论" in SkillHelper.get_actor_unlocked_skill_names(actorId).values():
				fengchu.append([actor, city])
			if actor.get_exp() >= 50000 and actor.get_level() >= 8:
				for attr in actor.LEARNING_ATTRS:
					var current = actor._get_attr_int_original(attr)
					if attr == "体":
						current = actor.get_max_hp(-1, -1, true)
					if current < 99:
						learningRequired.append([actor, city])
						break
			elif actor.get_exp() >= 70000:
				for attr in actor.LEARNING_ATTRS:
					var current = actor._get_attr_int_original(attr)
					if attr == "体":
						current = actor.get_max_hp(-1, -1, true)
					if current < 99:
						learningRequired.append([actor, city])
						break
			if actor.get_loyalty() != 100:
				var pol = actor.get_politics()
				if bestPolitician < 0 or pol > largestPol:
					bestPolitician = actorId
					largestPol = pol
			if actor.get_loyalty() < 70 and (actor.get_wisdom() >= 85 or actor.get_power() >= 85):
				lowLoyalty.append([actor, city])
			# 兵力补充只检查出阵的前十人
			if i < 10:
				totalSoldiers += actor.get_soldiers()
				maxSoldiers += DataManager.get_actor_max_soldiers(actorId)
			i += 1
		for actorId in city.get_ceil_actor_ids():
			var actor = ActorHelper.actor(actorId)
			if actor.get_loyalty() == 0:
				toPersuade.append([actor, city])
		if maxSoldiers > totalSoldiers and totalSoldiers + city.get_backup_soldiers() >= maxSoldiers:
			assignmentRequired.append(city)
		if city.get_loyalty() < 90:
			lowManagement.append(city)
		if city.get_defence() < 99:
			lowDefence.append(city)
		if not city.well_developed():
			var devProgress:float = city.get_land() / 999.0
			devProgress += city.get_eco() / 999.0
			devProgress += city.get_pop() / 50000.0
			if devProgress < leastDevProgress:
				leastDevProgress = devProgress
				if leastDeveloped.empty():
					leastDeveloped.append(city)
				else:
					leastDeveloped[0] = city
	if bestPolitician < 0:
		# 没人可以发动建言，直接结束
		FlowManager.add_flow("suggestion_done")
		return
	# 如果禁读书，不提醒经验培养
	if DataManager.get_game_setting("武将成长") in ["禁读书", "就不加"]:
		learningRequired = []
	DataManager.set_env("内政.建言武将", bestPolitician)
	var cityCheckings = [
		lowDefence,
		lowManagement,
		leastDeveloped,
		assignmentRequired
	]
	var cityNotices = [
		"需要防灾修缮",
		"统治度较低\n可能影响安定和税收",
		"需要重点开发",
		"出阵武将士兵不足\n可使用预备兵补充",
	]
	var actorCheckings = [
		learningRequired,
		lowLoyalty,
		toPersuade,
	]
	var actorNotices = [
		"\n已有充足的经验\n可适当培养属性",
		"忠诚不足\n可考虑给予赏赐",
		"收监很久了，似乎有归降之意，可以尝试说服"
	]
	for i in cityCheckings.size():
		if cityCheckings[i].empty():
			continue
		var names = []
		var cityIds = []
		for city in cityCheckings[i]:
			cityIds.append(city.ID)
			if names.size() < 3:
				names.append(city.get_name())
			else:
				names[names.size() - 1] += "等{0}城市".format([cityCheckings[i].size()])
				break
		var msg = "{0}{1}".format(["、".join(names), cityNotices[i]])
		DataManager.common_variable["内政.建言"].append([msg, cityIds])
	for i in actorCheckings.size():
		if actorCheckings[i].empty():
			continue
		var lastActorId = -1
		var names = []
		var cityIds = []
		for item in actorCheckings[i]:
			var cityId = int(item[1].ID)
			cityIds.erase(cityId)
			cityIds.append(cityId)
			var actor = item[0]
			lastActorId = actor.actorId
			if names.size() < 3:
				names.append(actor.get_name())
			else:
				names[names.size() - 1] += "等{0}人".format([actorCheckings[i].size()])
				break
		var name = "、".join(names)
		if names.size() == 1 and lastActorId == bestPolitician:
			name = DataManager.get_actor_honored_title(lastActorId, bestPolitician)
		var msg = "{0}{1}".format([name, actorNotices[i]])
		DataManager.common_variable["内政.建言"].append([msg, cityIds])
	for i in fengchu.size():
		var info = fengchu[i]
		var msg = "{0}大才也\n虽平日荒唐，然岁终将近\n似将可大用，主公留意".format([
			DataManager.get_actor_honored_title(info[0].actorId, bestPolitician),
		])
		DataManager.common_variable["内政.建言"].append([msg, [info[1].ID]])
	if DataManager.common_variable["内政.建言"].empty():
		SceneManager.show_confirm_dialog("主公治下，政通人和\n是时候考虑开疆拓土了", bestPolitician)
		LoadControl.set_view_model(261)
	else:
		FlowManager.add_flow("suggestion_2")
	return

func suggestion_2():
	var suggester = DataManager.get_env_int("内政.建言武将")
	var suggestions = Array(DataManager.common_variable["内政.建言"])
	if suggestions.empty():
		FlowManager.add_flow("suggestion_done")
		return
	var suggestion = suggestions.pop_front()
	DataManager.common_variable["内政.建言"] = suggestions
	DataManager.twinkle_citys = suggestion[1]
	SceneManager.show_confirm_dialog(suggestion[0], suggester)
	LoadControl.set_view_model(261)
	return

# 建言开关
func suggestion_3():
	var suggestionOn:bool = true
	if DataManager.common_variable.has("内政.建言开关") and DataManager.common_variable["内政.建言开关"] == 0:
		suggestionOn = false
	var msg = "内政建言当前状态：启用\n是否关闭？"
	if not suggestionOn:
		msg = "内政建言当前状态：关闭\n是否启用？"
	SceneManager.show_yn_dialog(msg)
	SceneManager.actor_dialog.lsc.cursor_index = 1
	LoadControl.set_view_model(262)
	return

# 修改建言开关
func suggestion_4():
	var suggestionOn:bool = true
	if DataManager.common_variable.has("内政.建言开关") and DataManager.common_variable["内政.建言开关"] == 0:
		suggestionOn = false
	if suggestionOn:
		DataManager.common_variable["内政.建言开关"] = 0
		SceneManager.show_confirm_dialog("内政建言已关闭")
	else:
		DataManager.common_variable["内政.建言开关"] = 1
		SceneManager.show_confirm_dialog("内政建言已启用")
	LoadControl.set_view_model(263)
	return

func suggestion_done():
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no];
	var vstate_controlNo = DataManager.get_current_control_sort()
	var player:Player = DataManager.players[vstate_controlNo];
	var cityId = DataManager.get_actor_at_cityId(player.actorId);
	SceneManager.current_scene().cursor.show();
	DataManager.player_choose_city = cityId;
	SceneManager.current_scene().set_city_cursor_position(cityId);
	FlowManager.add_flow("player_start")
	return
