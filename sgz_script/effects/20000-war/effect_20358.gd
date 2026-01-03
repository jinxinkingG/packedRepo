extends "effect_20000.gd"

#兴乱主动技
#【兴乱】大战场，主动技。选择“本次战争中，未与你发生白刃战的1个敌将”为目标（非主将，非太守府），才能发动：你与之强制进入白刃战。每回合限1次

const EFFECT_ID = 20358
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 10

# 发动主动技
func effect_20358_start():
	if not assert_action_point(actorId, COST_AP):
		return
	var targets = []
	for targetId in get_combat_targets(me, true):
		if targetId in me.get_war_attacked_actors():
			continue
		if targetId in me.get_war_defended_actors():
			continue
		var wa = DataManager.get_war_actor(targetId)
		if targetId == wa.get_main_actor_id():
			continue
		var terrian = map.get_blockCN_by_position(wa.position)
		if terrian == "太守府":
			continue
		targets.append(targetId)
	var msg = "选择敌军发动【{0}】".format([ske.skill_name])
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

# 已选定队友
func effect_20358_2():
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	var msg = "消耗{0}机动力，发动【{1}】\n强制攻击{2}\n可否？".format([
		COST_AP, ske.skill_name, targetWA.get_name(),
	])
	play_dialog(actorId, msg, 2, 2001, true)
	map.next_shrink_actors = [actorId, targetId]
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

# 执行
func effect_20358_3():
	ske.cost_ap(COST_AP, true)
	ske.cost_war_cd(1)
	var targetId = DataManager.get_env_int("目标")
	var msg = "{0}播乱天下\n汝何能独存？".format([
		DataManager.get_actor_self_title(actorId),
	])
	play_dialog(actorId, msg, 0, 2002)
	map.next_shrink_actors = [actorId, targetId]
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_20358_4():
	var targetId = DataManager.get_env_int("目标")
	map.next_shrink_actors = []
	start_battle_and_finish(actorId, targetId)
	return
