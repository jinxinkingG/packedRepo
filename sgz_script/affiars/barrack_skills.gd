extends "affairs_base.gd"

func _init()->void :
	LoadControl.view_model_name = "内政-玩家-步骤";
	FlowManager.bind_import_flow("skill_list", self, "skill_list");
	FlowManager.bind_import_flow("skill_confirm_deal", self, "skill_confirm_deal");
	FlowManager.bind_import_flow("skill_deal", self, "skill_deal");
	DataManager.common_variable["列表页码"] = 0
	return

func _input_key(delta:float):
	var scene_affiars:Control = SceneManager.current_scene();
	var top = SceneManager.lsc_menu_top;
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	match view_model:
		350:
			if Global.wait_for_choose_skill("", "enter_barrack_menu"):
				var skill = DataManager.get_env_array("目标项")
				if skill[0] == -1:
					var page = DataManager.get_env_int("列表页码")
					if skill[1] == "下一页":
						DataManager.set_env("列表页码", page + 1)
						FlowManager.add_flow("skill_list")
						return
				DataManager.set_env("当前武将", skill[0])
				DataManager.set_env("选定技能", skill[1])
				FlowManager.add_flow("skill_confirm_deal")
		352:
			wait_for_yesno("skill_deal", "skill_list")
	return

func _get_actor_skills(actorId:int, cityId:int, checkGlobal:bool = false):
	var ret = []
	for skill in SkillHelper.get_actor_active_skills(actorId):
		if checkGlobal and not skill.has_feature("全境发动"):
			continue
		for effect in SkillHelper.get_skill_effects(actorId, skill, ["主动"]):
			if effect.sceneId > 10000:
				continue
			ret.append([actorId, skill.name, effect.id, {}])
	# TODO: 这里应该优化 flag 的显示
	for item in ret:
		var skv = SkillHelper.get_skill_variable(10000, item[2], item[0])
		if skv["turn"] > 0 and skv["value"] != null and typeof(skv["value"]) == TYPE_DICTIONARY:
			item[3] = skv["value"]["flags"]
	return ret

func get_skills(thisCityOnly:bool=false):
	DataManager.game_trace("")
	var city = clCity.city(DataManager.player_choose_city)
	var skills = []
	for actorId in city.get_actor_ids():
		for skillInfo in _get_actor_skills(actorId, city.ID):
			skills.append(skillInfo)
	skills.sort_custom(self, "skills_sort")
	if thisCityOnly:
		return skills
	DataManager.game_trace("LOCAL_SKILLS")
	# 其他城市的全势力技能
	for otherCity in clCity.all_cities([city.get_vstate_id()]):
		if otherCity.ID == city.ID:
			continue
		for otherActorId in otherCity.get_actor_ids():
			for skillInfo in _get_actor_skills(otherActorId, otherCity.ID, true):
				skills.append(skillInfo)
	skills.sort_custom(self, "skills_sort")
	DataManager.game_trace("ALL_SKILLS")
	return skills

func skill_list():
	var pre_model = int(LoadControl.get_view_model());
	SceneManager.hide_all_tool();
	var scene_affiars:Control = SceneManager.current_scene();
	scene_affiars.cursor.hide();
	DataManager.twinkle_citys = [DataManager.player_choose_city];
	var skills = get_skills()
	if skills.empty():
		LoadControl._affiars_error("本城武将目前\n没有可发动的内政型主动技");
		return ;
	
	SceneManager.show_unconfirm_dialog("发动何人之内政技能？");
	_bind_menu(skills)
	SceneManager.lsc_menu_top.lsc.cursor_index = 0;
	SceneManager.lsc_menu_top.show();
	LoadControl.set_view_model(350)
	return

func skills_sort(a:Dictionary, b:Dictionary):
	return false

func _bind_menu(skills):
	var page = DataManager.get_env_int("列表页码")
	var pageSize = 7
	if skills.size() > pageSize:
		pageSize = 6
	var maxPage = int((skills.size() - 1) / pageSize)
	maxPage = max(0, maxPage)
	if page < 0:
		page = maxPage
	if page > maxPage:
		page = 0
	skills = skills.slice(page * pageSize, min(skills.size() - 1, page * pageSize + pageSize - 1))
	DataManager.set_env("列表页码", page)

	var items = []
	var values = []
	for skill in skills:
		values.append(skill)
		var actorId = int(skill[0])
		var skillName = str(skill[1])
		var effectId = int(skill[2])
		var flags = Dictionary(skill[3])
		var actor = ActorHelper.actor(actorId)
		var msg = "{0} （{1}）".format([skillName, actor.get_name()])
		if not flags.empty():
			var flagName = flags.keys()[0]
			msg += " [{0}]：{1}".format([flagName, flags[flagName]])
		items.append(msg)
	if maxPage > 0:
		items.append("下一页")
		values.append([-1, "下一页"])
	DataManager.set_env("列表值", values)
	SceneManager.lsc_menu_top.set_lsc()
	SceneManager.lsc_menu_top.lsc.columns = 1
	SceneManager.lsc_menu_top.lsc.items = items
	
	SceneManager.lsc_menu_top.lsc._set_data()
	SceneManager.lsc_menu_top.show()
	SceneManager.lsc_menu_top.lsc.cursor_index = -1
	return

func skill_confirm_deal():
	var scene_affiars:Control = SceneManager.current_scene();
	scene_affiars.cursor.hide();
	DataManager.twinkle_citys = [DataManager.player_choose_city];
	SceneManager.hide_all_tool();
	
	var skill = DataManager.common_variable["选定技能"]
	SceneManager.show_yn_dialog("发动" + skill + "？")
	SceneManager.lsc_menu.show_orderbook(true);
	if skill in ["腾龙"]:
		SceneManager.actor_dialog.lsc.cursor_index = 1
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(352)
	return

func skill_deal():
	LoadControl.set_view_model(-1);
	var actorId = int(DataManager.common_variable["当前武将"])
	var skill = str(DataManager.common_variable["选定技能"])
	SkillHelper.player_choose_skill(actorId, skill)
	return
