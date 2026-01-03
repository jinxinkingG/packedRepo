extends "effect_20000.gd"

# 探明主动技
#【探明】大战场，主动技。你可以消耗5点机动力，指定一个你方武将，直到你方下回合之前，该武将免疫对方陷阱伤害，且无法被定止，每个回合限1次。

const EFFECT_ID = 20660
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 5
const BUFF_NAME = "探明"

func check_AI_perform_20000()->bool:
	# AI 暂不发动
	return false

func effect_20660_start() -> void:
	if not assert_action_point(actorId, COST_AP):
		return
	var targets = get_teammate_targets(me)
	if targets.empty():
		var msg = "没有合适的【{0}】目标".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return

	var msg = "选择【{0}】目标".format([ske.skill_name])
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20660_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	var msg = "消耗{0}机动力\n对{1}发动【{2}】\n可否？".format([
		COST_AP, targetWA.get_name(), ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20660_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	ske.cost_ap(COST_AP, true)
	ske.cost_war_cd(1)
	ske.set_war_buff(targetId, BUFF_NAME, 1)
	ske.war_report()
	var msg = "地利敌情，吾已探知\n虽蹈危地，亦当无虞\n（{0}获得1回合 [{1}]\n（期间免疫定止和陷阱伤害".format([
		targetWA.get_name(), BUFF_NAME,
	])
	play_dialog(actorId, msg, 2, 2999)
	return
