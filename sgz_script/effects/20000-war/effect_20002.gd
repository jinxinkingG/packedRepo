extends "effect_20000.gd"

#智局主动技 #位移
#【智局】大战场，主动技。你可以选择己方两名武将，消耗5机动力发动。选定的两名武将交换位置。每个回合限1次。

const EFFECT_ID = 20002
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 5

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_choose_actor(FLOW_BASE + "_3")
	return

func on_view_model_2002():
	wait_for_yesno(FLOW_BASE + "_4")
	return

func on_view_model_2003():
	wait_for_skill_result_confirmation()
	return

func effect_20002_start():
	if not assert_action_point(me.actorId, COST_AP):
		return
	var targets = get_teammate_targets(me)
	if targets.size() < 2:
		LoadControl._error("队友不足，不可发动{0}".format([ske.skill_name]))
		return;
	if not wait_choose_actors(targets, "请选择{0}调换位置的第1名武将".format([ske.skill_name])):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20002_2():
	var selected = get_env_int("目标")
	set_env("智局目标", [selected])
	var targets = get_teammate_targets(me)
	targets.erase(selected)
	if not wait_choose_actors(targets, "请选择{0}调换位置的第2名武将".format([ske.skill_name])):
		return
	LoadControl.set_view_model(2001)
	return

func effect_20002_3():
	var selected = get_env_int("目标")
	var targets = get_env_int_array("智局目标")
	targets.append(selected)
	set_env("智局目标", targets)
	var msg = "消耗{0}点机动力\n可否？".format([COST_AP])
	play_dialog(me.actorId, msg, 2, 2002, true)
	map.clear_can_choose_actors()
	map.next_shrink_actors = [me.actorId, targets[0], targets[1]]
	return

func effect_20002_4():
	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	var targets = get_env_int_array("智局目标")
	ske.swap_war_actor_positions(targets[0], targets[1])
	var msg = "{0}与{1}位置交换成功!".format([
		ActorHelper.actor(targets[0]).get_name(),
		ActorHelper.actor(targets[1]).get_name(),
	])
	ske.war_report()
	play_dialog(me.actorId, msg, 1, 2003)
	return
