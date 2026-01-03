extends "effect_10000.gd"

# 恣睢主动技
#【恣睢】内政，君主主动技。你方势力城池数不大于3座时，你可指定1个不相邻的势力发动：你获得目标势力君主的1个技能，直到本月结束。

const EFFECT_ID = 10137
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_10137_start() -> void:
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	if clCity.all_cities([city.get_vstate_id()]).size() > 3:
		var msg = "城池数 > 3\n不可发动【{0}】".format([ske.skill_name])
		play_dialog(actorId, msg, 2, 2999)
		return

	var choices = []
	var excluded = []
	for connectedCityId in city.get_connected_city_ids():
		var connectedCity = clCity.city(connectedCityId)
		excluded.append(connectedCity.get_vstate_id())
	excluded.append(city.get_vstate_id())
	for vs in clVState.all_vstates(true):
		if vs.id in excluded:
			continue
		choices.append(vs)

	if choices.empty():
		var msg = "没有合适的目标势力\n不可发动【{0}】".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return

	var items = []
	var values = []
	for vs in choices:
		var lord = vs.get_lord()
		var skills = SkillHelper.get_actor_skills(lord.id, 10000, true)
		for skill in skills:
			var msg = "{0}：{1}".format([vs.get_lord_name(), skill.name])
			items.append(msg)
			values.append([vs.id, lord.id, skill.name])
	if items.empty():
		var msg = "目标势力君主无合适的技能\n不可发动【{0}】".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return
	# 先记录下来，临时用于翻页，减少重复判断
	ske.affair_set_skill_val([items, values, 0], 1)
	goto_step("options")
	return

func effect_10137_options() -> void:
	var options = ske.affair_get_skill_val_array()
	var items = options[0]
	var values = options[1]
	var page = int(options[2])
	# 翻页，每页 12 项
	var pageSize = 12
	var maxPage = int((items.size() - 1) / pageSize)
	maxPage = max(0, maxPage)
	if page < 0:
		page = maxPage
	if page > maxPage:
		page = 0
	items = items.slice(page * pageSize, min(items.size() - 1, page * pageSize + pageSize - 1))
	values = values.slice(page * pageSize, min(values.size() - 1, page * pageSize + pageSize - 1))
	if maxPage > 0:
		items.append("上一页")
		values.append([-1, page - 1, ""])
		items.append("下一页")
		values.append([-1, page + 1, ""])
	SceneManager.show_unconfirm_dialog("选择本月可获得的技能", actorId)
	SceneManager.bind_top_menu(items, values, 2)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_item(FLOW_BASE + "_selected")
	return

func effect_10137_selected() -> void:
	var selected = DataManager.get_env_array("目标项")
	var vsId = selected[0]
	var lordId = selected[1]
	var skillName = selected[2]
	if vsId == -1: # 翻页
		var options = ske.affair_get_skill_val_array()
		options[2] = lordId # 指定页码
		goto_step("options")
		return
	var msg = "获得{0}的{1}\n可否？".format([
		ActorHelper.actor(lordId).get_name(), skillName
	])
	play_dialog(actorId, msg, 1, 2001, true)
	DataManager.twinkle_citys = clCity.all_city_ids([vsId])
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_10137_confirmed() -> void:
	var selected = DataManager.get_env_array("目标项")
	var vsId = selected[0]
	var lordId = selected[1]
	var skillName = selected[2]
	SkillHelper.add_actor_scene_skill(10000, actorId, skillName, 1, actorId, ske.skill_name)
	var msg = "国虽小，自有腾挪之术\n{0}鞭长莫及，能奈我何？\n（本月获得【{1}】".format([
		ActorHelper.actor(lordId).get_name(), skillName
	])
	play_dialog(actorId, msg, 1, 2999)
	DataManager.twinkle_citys = clCity.all_city_ids([vsId])
	return
