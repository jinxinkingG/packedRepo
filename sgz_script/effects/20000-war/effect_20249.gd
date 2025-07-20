extends "effect_20000.gd"

#惊鸿主动技 #禁用技能 #学习技能
#【惊鸿】大战场,限定技。选择对方 1 名男性武将发动。直到回合结束前，你夺取其所有技能。

const EFFECT_ID = 20249
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const REPORT_LIMIT = 4

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_4")
	return

func effect_20249_start():
	var targets = []
	for targetId in get_enemy_targets(me):
		if not ActorHelper.actor(targetId).is_male():
			# 仅限男性
			continue
		if SkillHelper.get_actor_skill_names(targetId).empty():
			continue
		targets.append(targetId)
	if not wait_choose_actors(targets, "选择敌军发动【{0}】".format([ske.skill_name])):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20249_2():
	var targetId = get_env_int("目标")
	var msg = "对{1}发动{0}\n暂时夺取其所有技能\n可否？".format([
		ske.skill_name, ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func effect_20249_3():
	var targetId = get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	ske.cost_war_cd(99999)
	for skill in SkillHelper.get_actor_skill_names(targetId):
		if not ske.ban_war_skill(targetId, skill, 1):
			continue
		ske.add_war_skill(ske.skill_actorId, skill, 1)
	var msg = "一瞥惊鸿去，万法照影来"
	report_skill_result_message(ske, 2002, msg, 2)
	return

func effect_20249_4():
	report_skill_result_message(ske, 2002)
	return
