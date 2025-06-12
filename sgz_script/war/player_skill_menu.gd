extends Resource

const PAGE_SIZE = 6

#武将用技能
func _init() -> void:
	LoadControl.view_model_name = "战争-玩家-步骤";
	FlowManager.bind_import_flow("skill_menu_start", self)
	FlowManager.bind_import_flow("skill_menu", self)
	DataManager.common_variable["列表页码"] = 0
	return

#按键操控
func _input_key(delta: float):
	var scene_war:Control = SceneManager.current_scene();
	var war_map = scene_war.war_map;
	var bottom = SceneManager.lsc_menu;
	var top = SceneManager.lsc_menu_top;
	var actorId = DataManager.player_choose_actor
	match LoadControl.get_view_model():
		120:#技能列表
			if not Global.wait_for_choose_skill("", "player_ready"):
				return
			var skill = DataManager.get_env_str("目标项")
			if skill == "" or skill.begins_with("-"):
				SceneManager.show_unconfirm_dialog("此技能不可发动", actorId)
				top.show()
				LoadControl.set_view_model(120)
				return
			if skill == "下一页":
				var page = DataManager.get_env_int("列表页码")
				DataManager.set_env("列表页码", page + 1)
				FlowManager.add_flow("skill_menu")
				return
			if not SkillHelper.player_choose_skill(actorId, skill):
				return
	return

#展示大战场技能列表
func skill_menu_start():
	var actorId = int(DataManager.player_choose_actor)
	var key = "战争.主动技.允许.{0}".format([actorId])
	DataManager.set_env(key, "1")
	# 触发判断，是否可发动主动技，不支持 flow，可以在 key 中返回错误信息
	SkillHelper.auto_trigger_skill(actorId, 20023, "")
	var flag = DataManager.get_env_str(key)
	if flag != "1":
		if flag == "0" or flag == "":
			flag = "不可"
		LoadControl._error(flag, actorId, 3)
		return
	FlowManager.add_flow("skill_menu")
	return

func skill_menu():
	var actorId = DataManager.player_choose_actor
	var skills = SkillHelper.get_actor_war_skills(actorId)
	if skills.empty():
		LoadControl._error("未习得任何大战场技能\n请下达其他命令",actorId);
		return;
	var maxPage = int((skills.size() - 1) / PAGE_SIZE)
	var page = DataManager.get_env_int("列表页码")
	if page < 0:
		page = maxPage
	if page > maxPage:
		page = 0
	DataManager.set_env("列表页码", page)
	var items = []
	var values = []
	var from = page * PAGE_SIZE
	var to = min(from + PAGE_SIZE, skills.size()) - 1
	skills = skills.slice(from, to)
	for skillSetting in skills:
		var text = "{名称}    {说明}".format(skillSetting)
		var name = skillSetting["名称"]
		if not skillSetting["可用"]:
			text += "#C52,52,52"
			name = "-" + name
		items.append(text)
		values.append(name)
	if maxPage > 0:
		items.append("下一页")
		values.append("下一页")
	
	SceneManager.lsc_menu_top.set_lsc()
	SceneManager.lsc_menu_top.lsc.columns = 1
	SceneManager.lsc_menu_top.lsc.items = items
	SceneManager.lsc_menu_top.lsc._set_data()
	if DataManager.get_current_scene_id() == 20000:
		var wa = DataManager.get_war_actor(actorId)
		if wa != null:
			SceneManager.lsc_menu_top.status.rect_position = Vector2(420, 290)
			SceneManager.lsc_menu_top.status.rect_size = Vector2(140, 80)
			SceneManager.lsc_menu_top.status.bbcode_text = "机动: {0}\n五行: [b][color={1}]{2} {3}[/color][/b]".format([
				wa.action_point, wa.get_five_phases_color_code(),
				wa.get_five_phases_str(), wa.poker_point,
			])
			SceneManager.lsc_menu_top.status.show()
	var msg = "发动哪个技能？"
	SceneManager.show_unconfirm_dialog(msg, actorId)
	SceneManager.lsc_menu_top.show()
	DataManager.set_env("列表值", values)
	SceneManager.lsc_menu_top.set_memo("查看技能说明")
	LoadControl.set_view_model(120)
	return
