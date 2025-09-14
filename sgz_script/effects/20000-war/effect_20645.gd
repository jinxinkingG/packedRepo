extends "effect_20000.gd"

# 龙纹主动技
#【龙纹】大战场，主将主动技。已解锁的技能名中含“龙”或“战”的你方武将，方可成为该技能的目标：若其与你同姓，其体力回复10点；若不同姓，你体力降低10点。然后你令其获得<轻甲>。每回合限1次。

const EFFECT_ID = 20645
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const RECOVER_HP = 10
const COST_HP = 10
const BUFF_SKILL = "轻甲"

func effect_20645_start() -> void:
	var targets = []
	for targetId in get_teammate_targets(me):
		for skillName in SkillHelper.get_actor_unlocked_skill_names(targetId).values():
			if "龙" in skillName or "战" in skillName:
				targets.append(targetId)
				break
	if targets.empty():
		var msg = "没有可以发动【{0}】的目标".format([ske.skill_name])
		play_dialog(actorId, msg, 2, 2999)
		return
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20645_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	
	if targetWA.actor().get_first_name() == actor.get_first_name():
		if not targetWA.actor().is_injured():
			var msg = "{0}并未受伤".format([targetWA.get_name()])
			play_dialog(actorId, msg, 2, 2999)
			return
		var recovered = ske.change_actor_hp(targetId, RECOVER_HP)
		ske.cost_war_cd(1)
		ske.war_report()

		var msg = "{0}努力\n勿负吾宗之望".format([
			DataManager.get_actor_honored_title(targetId, actorId)
		])
		report_skill_result_message(ske, 2001, msg, 1)
		return

	if not assert_min_hp(actorId, COST_HP):
		return

	var costed = ske.change_actor_hp(actorId, -COST_HP)
	ske.add_war_skill(targetId, BUFF_SKILL, 1)
	ske.cost_war_cd(1)
	ske.war_report()

	var msg = "{0} ……\n吾儿若在，亦当如此风采\n取我甲来！".format([
		DataManager.get_actor_honored_title(targetId, actorId),
	])
	report_skill_result_message(ske, 2001, msg, 1)
	return

func on_view_model_2001() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20645_report() -> void:
	report_skill_result_message(ske, 2001)
	return
