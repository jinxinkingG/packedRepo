extends "effect_20000.gd"

#解音，主动技部分，负责设变量
#【解音】大战场,主动技。你可以消耗2点机动力，指定一个你方武将，该武将本回合伤兵计命中率加x，x＝该武将点数%，每回合限1次

const EFFECT_ID = 20120
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const PASSIVE_EFFECT_ID = 20121
const COST_AP = 2

func effect_20120_start():
	if not assert_action_point(actorId, COST_AP):
		return
	var targets = get_teammate_targets(me)
	if not wait_choose_actors(targets, "选择队友发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20120_2():
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	ske.change_actor_scheme_chance(targetId, targetWA.poker_point)
	ske.war_report()

	var msg = "音律所蕴，亦合策道"
	report_skill_result_message(ske, 2001, msg, 1)
	return

func on_view_model_2001()->void:
	wait_for_pending_message(FLOW_BASE + "_3")
	return

func effect_20120_3()->void:
	report_skill_result_message(ske, 2001)
	return
