extends "effect_20000.gd"

# 承达主动技
#【承达】大战场，主动技。你可选择己方任意武将，令<甄识>改为对其生效。每回合限1次。

const EFFECT_ID = 20566
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const ZHENSHI_EFFECT_ID = 20565

func effect_20566_start() -> void:
	var targets = get_teammate_targets(me)
	targets.append(actorId)
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20566_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var msg = "令【甄识】改为对{0}生效\n可否？".format([
		DataManager.get_actor_honored_title(targetId, actorId),
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_confirmed")
	return

func effect_20566_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	ske.set_war_skill_val(targetId, 99999, ZHENSHI_EFFECT_ID)
	ske.cost_war_cd(1)
	ske.war_report()

	var msg = "澄明通达，自可兼济\n（【甄识】对{0}生效\n（技能范围扩大".format([
		ActorHelper.actor(targetId).get_name(),
	])
	SkillHelper.update_all_skill_buff(ske.skill_name)
	play_dialog(actorId, msg, 1, 2999)
	return
