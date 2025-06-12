extends "effect_20000.gd"

#娇妹限定技 #学习技能
#【娇妹】大战场，限定技。你可以选择一个己方“孙”姓武将的一个技能（阴阳转换技除外），复刻后附加给自己，直到本场战争结束。

const EFFECT_ID = 20307
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const SKILL_NAME = "娇妹"
const FIRST_NAME = "孙"

func effect_20307_start():
	var targets = []
	for targetId in get_teammate_targets(me):
		if ActorHelper.actor(targetId).get_first_name() != FIRST_NAME:
			continue
		if _get_available_skills(targetId).empty():
			continue
		targets.append(targetId)
	var msg = "选择目标发动【{0}】".format([SKILL_NAME])
	if not wait_choose_actors(targets, msg, true):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20307_2():
	var targetId = get_env_int("目标")
	var skills = _get_available_skills(targetId)
	var menu_array = []
	var value_array = []
	for skillName in skills:
		value_array.append(skillName)
		menu_array.append(skillName)
	var msg = "选择哪个技能？"
	SceneManager.show_unconfirm_dialog(msg, me.actorId)
	bind_menu_items(menu_array, value_array, 1)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001():
	wait_for_choose_skill(FLOW_BASE + "_3")
	return

# 已选定技能，执行
func effect_20307_3():
	var targetId = get_env_int("目标")
	var skill = get_env_str("目标项")
	var last = ske.get_war_skill_val_str()

	ske.cost_war_cd(99999)
	ske.add_war_skill(actorId, skill, 99999)
	if last != "":
		ske.remove_war_skill(actorId, last)
	ske.set_war_skill_val(skill)

	var msg = "谢过{0}啦\n【{1}】有何难？\n小妹一学就会".format([
		DataManager.get_actor_honored_title(targetId, me.actorId),
		skill
	])
	play_dialog(me.actorId, msg, 1, 2002)
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_20307_4():
	report_skill_result_message(ske, 2003)
	return

func on_view_model_2003():
	wait_for_pending_message(FLOW_BASE + "_4")
	return

#绑定可获取的技能列表选项
func _get_available_skills(targetId:int)->PoolStringArray:
	var ret = []
	for skill in SkillHelper.get_actor_basic_skills(targetId):
		if skill.has_feature("转换"):
			continue
		ret.append(skill.name)
	for dic in SkillHelper.get_actor_scene_skills(targetId):
		ret.erase(dic["skill_name"])
	return ret
