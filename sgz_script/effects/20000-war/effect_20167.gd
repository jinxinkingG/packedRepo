extends "effect_20000.gd"

#破阵限定技 #禁用技能
#【破阵】大战场,限定技。指定一个对方武将，选择其一个技能，沉默该技能3日

const EFFECT_ID = 20167
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20167_start():
	var targets = []
	for targetId in get_enemy_targets(me, true):
		if get_valuable_skill_list(targetId).empty():
			continue
		if SkillHelper.actor_has_skills(targetId, ["贞烈"]):
			continue
		targets.append(targetId)
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

# 已选定对手
func effect_20167_2():
	var targetId = get_env_int("目标")
	var msg = "禁用哪个技能？"
	SceneManager.show_unconfirm_dialog(msg, self.actorId)
	if not _bind_skill_menu(targetId):
		msg = "{0}没有可以禁用的技能".format([
			ActorHelper.actor(targetId).get_name()
		])
		play_dialog(me.actorId, msg, 2, 2009)
		return
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001():
	wait_for_choose_skill(FLOW_BASE + "_3")
	return

# 已选定技能，执行
func effect_20167_3():
	var targetId = get_env_int("目标")
	var skill = get_env_str("目标项")

	ske.cost_war_cd(99999)
	if not ske.ban_war_skill(targetId, skill, 6):
		play_dialog(me.actorId, "【{0}】不可禁用".format([skill]), 2, 2002)
		return

	var msg = "敌隙可乘，破阵无忧！"
	report_skill_result_message(ske, 2009, msg, 0)
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")

func on_view_model_2009():
	wait_for_pending_message(FLOW_BASE + "_4")
	return

func effect_20167_4():
	report_skill_result_message(ske, 2009)
	return

#绑定可夺取的技能列表选项
func _bind_skill_menu(targetId:int)->bool:
	var menu_array = []
	var value_array = []
	var skills = get_valuable_skill_list(targetId)
	for skillName in skills:
		value_array.append(skillName)
		menu_array.append(skillName)
	if value_array.empty():
		return false
	bind_menu_items(menu_array, value_array, 1)
	return true
