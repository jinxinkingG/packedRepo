extends Resource


func _init()->void :
	pass

func load_story(playerVstateId:int, story_no:int)->bool:
	DataManager.set_env("剧情.关卡", 1)
	DataManager.set_env("剧情.势力", playerVstateId)
	DataManager.set_env("剧情.对白", [])
	var story_data = StaticManager.load_story_data(playerVstateId, story_no)
	if story_data.empty():
		return false
	var p:Player = DataManager.players[0]
	# 设定玩家身份和君主
	p.actorId = int(story_data["player"]["leader"])
	clVState.vstate(playerVstateId).set_lord(p.actorId)
	var targetCityId = int(story_data["city"])
	var targetVstateId = 17
	clCity.city(targetCityId).set_vstate_id(targetVstateId)

	# 初始化数据
	var playerWV = null
	var enemyWV = null
	var wvs = []
	for side in ["防守方", "攻击方"]:
		var vstateId = targetVstateId
		if side == story_data["player"]["side"]:
			vstateId = playerVstateId
		var wv = War_Vstate.new(vstateId)
		wv.side = side
		wv.from_cityId = - 1
		if wv.side == "防守方":
			wv.from_cityId = targetCityId
		wv.init_actors = []
		wv.vstateId = targetVstateId
		if wv.side == story_data["player"]["side"]:
			wv.vstateId = vstateId
			playerWV = wv
		else:
			enemyWV = wv
		wv.main_actorId = - 1
		wv.money = 1000
		wv.rice = 1000
		wvs.append(wv)
	var wf = DataManager.new_war_fight(-1, targetCityId)
	wf.defenderWV = wvs[0]
	wf.attackerWV = wvs[1]
	wf.fromVstateId = playerVstateId

	# 设定战场所在和指定数据
	wf.warDirection = int(story_data["direction"])
	playerWV.vstate().set_lord(int(story_data["player"]["leader"]))
	enemyWV.vstate().set_lord(int(story_data["enemy"]["leader"]))
	playerWV.money = int(story_data["player"]["gold"])
	playerWV.rice = int(story_data["player"]["rice"])
	enemyWV.money = int(story_data["enemy"]["gold"])
	enemyWV.rice = int(story_data["enemy"]["rice"])

	# 初始化双方武将数据
	_init_war_actors_with_side(story_data["player"]["heroes"], playerWV)
	_init_war_actors_with_side(story_data["enemy"]["heroes"], enemyWV)
	
	# 初始化对话
	for dialog in story_data["dialogs"]:
		var dialog_data = {
			"触发条件": dialog["condition"],
			"文字": dialog["text"],
			"武将": int(dialog["hero"]),
			"心情": int(dialog["face"])
		}
		DataManager.common_variable["剧情.对白"].append(dialog_data)

	wf.init_war()
	LoadControl.end_script()
	FlowManager.clear_bind_method()
	FlowManager.add_flow("go_to_scene|res://scene/scene_war/scene_war.tscn")
	FlowManager.add_flow("war_run_start")
	return true

func _init_war_actors_with_side(actor_data_list, wv:War_Vstate):
	var props_dict = {
		"hp":"体","power":"武","int":"知","leadership":"统",
		"troops":"兵力","level":"等级","exp":"经验",
	}
	for actor_data in actor_data_list:
		var actorId = int(actor_data["id"])
		var actor = ActorHelper.actor(actorId)
		actor.set_status_officed()
		actor.set_hp(actor.get_max_hp())
		for prop in actor_data.keys():
			# 忽略不允许设置的属性
			if not props_dict.has(prop):
				continue
			var attr = props_dict[prop]
			# 忽略不存在的属性
			if not actor._has_attr(attr):
				continue
			var val = actor_data[prop]
			match typeof(actor._get_attr(attr)):
				TYPE_STRING:
					actor._set_attr_str(attr, val)
				_:
					val = int(val)
					if val != -1:
						# 经验需要特殊处理
						if attr == "经验":
							actor.set_exp(val)
						else:
							actor._set_attr_int(attr, val)
		wv.init_actors.append(actorId)
	wv.main_actorId = wv.init_actors[0]
	return true

func get_story_dialog(condition:String, pop_it:bool = true)->Dictionary:
	if (DataManager.game_mode2 == 0):
		DataManager.common_variable.erase("剧情.对白");
		return {};
	if ( not DataManager.common_variable.has("剧情.对白")):
		return {};
	var read_array = Array(DataManager.common_variable["剧情.对白"]);
	for dic_dialog in read_array:
		if (dic_dialog["触发条件"] == condition):
			var result = Dictionary(dic_dialog).duplicate();
			if (pop_it):
				read_array.erase(dic_dialog);
			return result;
	return {};
