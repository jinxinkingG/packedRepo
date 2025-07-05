extends "effect_20000.gd"

#奋困主动技 #禁用技能
#【奋困】大战场,主动技。你需选择除<逢亮>以外的1个技能直到战争结束前禁用，才能发动。立刻执行1次机动力恢复(等同于回合初始恢复)。
#【伺动】大战场，锁定技。己方武将发动<奋困>时，你的技能也置入其可禁用的列表中；若选择禁用了你的技能，结束阶段前该效果不能再次使用。

const EFFECT_ID = 20200
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20200_start():
	var skillNames = []
	if actor.get_side() == "道":
		# 兼容易经
		for dic in SkillHelper.get_actor_scene_skills(actorId):
			if not dic.has("skill_name"):
				continue
			if not dic.has("source") or dic["source"] != "易经":
				continue
			var skillName = str(dic["skill_name"])
			if SkillHelper.actor_skill_disabled(20000, me.actorId, skillName):
				continue
			skillNames.append(skillName)
	else:
		for skill in SkillHelper.get_actor_basic_skills(actorId):
			skillNames.append(skill.name)
		for dic in SkillHelper.get_actor_scene_skills(actorId):
			skillNames.erase(dic["skill_name"])
	var extraSkillNames = []
	for targetId in get_teammate_targets(me, 999):
		var targetSkillNames = []
		for skill in SkillHelper.get_actor_basic_skills(targetId):
			targetSkillNames.append(skill.name)
		for dic in SkillHelper.get_actor_scene_skills(targetId):
			targetSkillNames.erase(dic["skill_name"])
		if not "伺动" in targetSkillNames:
			continue
		for skillName in targetSkillNames:
			extraSkillNames.append([targetId, skillName])
	var items = []
	var values = []
	for skill in skillNames:
		items.append(skill)
		values.append("{0}#{1}".format([skill, me.actorId]))
	for extraSkill in extraSkillNames:
		var targetId = extraSkill[0]
		var name = ActorHelper.actor(targetId).get_name()
		var skillName = extraSkill[1]
		items.append("{0}（{1}）".format([skillName, name]))
		values.append("{0}#{1}".format([skillName, targetId]))
	if items.empty():
		play_dialog(me.actorId, "没有可以丢弃的技能", 3, 2002)
		return
	SceneManager.show_unconfirm_dialog("丢弃哪个技能？", me.actorId)
	bind_menu_items(items, values, 2)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_skill(FLOW_BASE + "_2")
	return

func effect_20200_2():
	var item = get_env_str("目标项")
	set_env("战争.困奋.技能丢弃", item)
	var skill = item.split("#")[0]
	var targetId = me.actorId
	if item.find("#") > 0:
		targetId = int(item.split("#")[1])
	var source = ""
	if targetId != me.actorId:
		source = "（{0}）".format([ActorHelper.actor(targetId).get_name()])
	var msg = "丢弃【{0}】{2}\n发动【{1}】，回复机动力\n可否？".format([
		skill, ske.skill_name, source
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20200_3():
	var item = get_env_str("战争.困奋.技能丢弃")
	var skill = item.split("#")[0]
	var targetId = me.actorId
	if item.find("#") > 0:
		targetId = int(item.split("#")[1])
	#禁用选中的技能
	if not ske.ban_war_skill(targetId, skill, 99999):
		play_dialog(me.actorId, "【{0}】不可丢弃！".format([skill]), 2, 2003)
		return
	if targetId != me.actorId and skill != "伺动":
		#禁用伺动
		ske.ban_war_skill(targetId, "伺动", 1)
	# 记录当前机动力
	var currentAP = me.action_point
	# 初始化机动力
	me.action_point = 0
	me.recharge_action_point()
	var recover = me.action_point
	# 回写当前机动力
	me.action_point = currentAP
	ske.change_actor_ap(actorId, recover)

	var msg = "困顿之势，当奋起而破！"
	report_skill_result_message(ske, 2002, msg, 0)
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_4")
	return

func on_view_model_2003():
	wait_for_skill_result_confirmation(FLOW_BASE + "_start")
	return

func effect_20200_4():
	report_skill_result_message(ske, 2002)
	return
