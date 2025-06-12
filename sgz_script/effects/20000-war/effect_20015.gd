extends "effect_20000.gd"

#劫营主动技部分
#【劫营】大战场,主动技。选择1名非城地形的敌将，且消耗5机动力才能发动。你与目标进入白兵。仅在此次白兵战中，你的兵力变为500，兵种为全骑兵（不计入实际兵力）。每回合限一次。

const EFFECT_ID = 20015
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 5
const FLAG_NAME = "劫营"

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2", true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3", true)
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func check_AI_perform_20000()->bool:
	# 托管模式下不发动
	if me.war_vstate().delegated:
		skill_end_clear()
		return false
	if actor.get_hp() < 50:
		return false
	if me.action_point < COST_AP:
		return false
	var selectedId = -1
	var leastPower = 250 * 1000
	for targetId in get_enemy_targets(me):
		var targetActor = ActorHelper.actor(targetId)
		# 模拟计算士气
		var morale = me.calculate_battle_morale(targetActor.get_power(), targetActor.get_leadership(), 0)
		var power = morale * targetActor.get_soldiers()
		if power < leastPower:
			leastPower = power
			selectedId = targetId
	if selectedId < 0:
		return false
	set_env("目标", selectedId)
	return true

func effect_20015_AI_start():
	var targetId = get_env_int("目标")

	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	ske.set_war_skill_val(1, 1)
	ske.war_report()

	var msg = "夜袭敌军，挫其锐气!\n（{0}对{1}发动【劫营】".format([
		me.get_name(), ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(me.actorId, msg, 0, 2002)
	return

func effect_20015_start():
	if not assert_action_point(me.actorId, COST_AP):
		return
	var targets = get_enemy_targets(me)
	if not wait_choose_actors(targets, "选择敌军发动【劫营】"):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20015_2():
	var targetId = get_env_int("目标")
	var msg = "消耗{0}点机动力\n可否？".format([COST_AP])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func effect_20015_3():
	var targetId = get_env_int("目标")
	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	ske.set_war_skill_val(1, 1)
	ske.war_report()
	var msg = "夜袭{0}，挫其锐气!".format([
		ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(me.actorId, msg, 0, 2002)
	return

func effect_20015_4():
	var targetId = get_env_int("目标")
	start_battle_and_finish(me.actorId, targetId)
	return
