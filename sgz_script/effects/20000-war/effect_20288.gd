extends "effect_20000.gd"

#涉险主动技实现
#【涉险】大战场，主动技。6格范围内你没有其他队友且存在至少2个敌方武将的场合，你可选择1名敌将为目标，并消耗5机动力发动。你与之进入白刃战；仅在此次白刃战中，你兵力受到的损失只有一半计入实际兵力。每个回合限1次。

const EFFECT_ID = 20288
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const PASSIVE_EFFECT_ID = 20289
const COST_AP = 5

func effect_20288_start():
	if not assert_action_point(actorId, COST_AP):
		return
	if not get_teammate_targets(me).empty():
		var msg = "附近存在队友\n不可发动{0}".format([ske.skill_name])
		play_dialog(actorId, msg, 2, 2999)
		return
	var targetIds = get_enemy_targets(me)
	if targetIds.size() < 2:
		var msg = "附近敌军数量 < 2\n不可发动{0}".format([ske.skill_name])
		play_dialog(actorId, msg, 2, 2999)
		return
	targetIds = check_combat_targets(targetIds)
	if not wait_choose_actors(targetIds, "选择敌军发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20288_2():
	var targetId = DataManager.get_env_int("目标")
	var msg = "发动{0}，奇袭{1}\n可否？".format([
		ske.skill_name, ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20288_3():
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	ske.set_war_skill_val(actor.get_soldiers(), 1, PASSIVE_EFFECT_ID)
	ske.war_report()

	var msg = "今已成孤军深入之势\n死地则战！"
	play_dialog(actorId, msg, 0, 2002)
	return

func on_view_model_2002()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_20288_4():
	var targetId = DataManager.get_env_int("目标")
	start_battle_and_finish(actorId, targetId)
	return
