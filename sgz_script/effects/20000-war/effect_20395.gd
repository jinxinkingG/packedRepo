extends "effect_20000.gd"

# 【阴阳归道】易经附加技能，目前为易经专用
# 战争初始，自选阴阳两面的技能

const EFFECT_ID = 20395
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20019() -> bool:
	# 20019 比较特殊，需要由主将触发
	# 所以需要避免重复触发
	# 且需要额外判断一下自己的状态
	if ske.get_war_skill_val_int() > 0:
		return false
	ske.set_war_skill_val(1, 99999)
	if me.disabled or not me.has_position():
		return false
	if not actor.has_side():
		return false
	if not actor.get_side() in ["阴", "阳"]:
		return false
	return not _get_valid_skills().empty()

func effect_20395_start():
	var msg = "造化两仪，阴阳归道\n（{0}已转为「道」面".format([
		me.get_name(),
	])
	play_dialog(me.actorId, msg, 2, 2000)
	return

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_20395_2():
	var skills = _get_valid_skills()
	var limit = min(4, skills.size())
	var lst = []
	for i in skills.size():
		lst.append(skills[i])
	_set_selected_skills(Global.arrval(ske.get_skill_val(10000)))
	var prevSelected = 0
	for skill in _get_selected_skills():
		if skill in skills:
			prevSelected += 1
	var msg = "选择「道」面技能（{0}/{1}）\n「B」键确认".format([
		prevSelected, limit,
	])
	SceneManager.show_unconfirm_dialog(msg)
	bind_menu_items(lst, skills, 2)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001():
	var menu = SceneManager.lsc_menu_top
	var lsc = menu.lsc
	var selected = _get_selected_skills()

	# 预设的时候设置 set_selected_by_array 不好使
	# 只好在这里再设一遍
	var selectedIndexes = []
	for skill in selected:
		var idx = menu.lsc.items.find(skill)
		if idx >= 0:
			selectedIndexes.append(idx)
	menu.lsc.set_selected_by_array(selectedIndexes)

	var limit = min(4, lsc.items.size())
	if Global.is_action_pressed_BY() \
		and SceneManager.dialog_msg_complete():
			if lsc.get_selected_list().size() == limit:
				goto_step("3")
			else:
				var msg = "须选择 {1} 个技能（{0}/{1}）\n「A」键选择".format([
					lsc.get_selected_list().size(), limit
				])
				SceneManager.actor_dialog.rtlMessage.text = msg
			return
	var idx = wait_for_choose_skill("", false, false, true, 4)
	if idx >= 0:
		var skill = lsc.items[idx]
		if skill in selected:
			selected.erase(skill)
		else:
			selected.append(skill)
		_set_selected_skills(selected)
		var msg = "选择「道」面技能（{0}/{1}）\n「A」键选择".format([
			selected.size(), limit
		])
		if selected.size() == limit:
			msg = "选择「道」面技能（{0}/{1}）\n「B」键确认".format([
				limit, limit
			])
		SceneManager.actor_dialog.rtlMessage.text = msg
	return

func effect_20395_3():
	var lsc = SceneManager.lsc_menu_top.lsc
	var selected = []
	for i in lsc.get_selected_list():
		selected.append(lsc.items[i])
	ske.set_skill_val(selected, 99999, -1, 10000)
	var msg = "获得以下技能："
	var i = 0
	var unlocked = []
	for skill in selected:
		var sep = "、"
		if i % 2 == 0:
			sep = "\n"
		msg += sep + skill
		skill = skill.replace("（阳）", "")
		skill = skill.replace("（阴）", "")
		ske.add_war_skill(me.actorId, skill, 99999)
		unlocked.append(skill)
		i += 1
	me.dic_other_variable["临面"] = "道"
	# 清除不合理的附加技能
	for dic in SkillHelper.get_actor_scene_skills(actorId, 10000):
		var source = Global.dic_val(dic, "source", "")
		if source != "" and not source in unlocked:
			ske.ban_war_skill(actorId, dic["skill_name"], 99999)
	ske.cost_war_cd(99999)
	play_dialog(me.actorId, msg, 2, 2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation("")
	return

func _get_valid_skills()->PoolStringArray:
	var skills = []
	for side in ["阴", "阳"]:
		for skillName in SkillHelper.get_actor_unlocked_skill_names(actorId, side).values():
			var skill = StaticManager.get_skill(skillName)
			if skill.has_feature("转换"):
				continue
			skills.append(skill.name + "（" + side + "）")
	return skills

func _set_selected_skills(skills:Array)->void:
	var key = "战争.阴阳归道.{0}".format([me.actorId])
	DataManager.set_env(key, skills)
	return

func _get_selected_skills()->Array:
	var key = "战争.阴阳归道.{0}".format([me.actorId])
	return DataManager.get_env_array(key)
