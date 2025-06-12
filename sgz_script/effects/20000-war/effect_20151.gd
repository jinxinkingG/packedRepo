extends "effect_20000.gd"

#好施主动技
#【好施】大战场，主动技。选择一个你方武将，该武将获得你50%的机动力，以及最多获得你50%的兵力，至多加到2500兵力，每回合限1次。

const EFFECT_ID = 20151
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func on_view_model_2009():
	wait_for_skill_result_confirmation()
	return

# 发动主动技
func effect_20151_start():
	if me.action_point <= 0 and actor.get_soldiers() <= 0:
		play_dialog(me.actorId, "兵力与机动力不足", 2, 2009)
		return
	var targets = get_teammate_targets(me)
	var msg = "选择队友发动【{0}】".format([ske.skill_name])
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20151_2():
	var targetId = get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)

	var ap = int(me.action_point / 2)
	var soldiers = int(actor.get_soldiers() / 2)
	soldiers = min(soldiers, 2500 - targetActor.get_soldiers())
	soldiers = max(0, soldiers)
	var msg = "援助{0}：\n{1}机动力和{2}兵力\n可否？".format([
		targetActor.get_name(), ap, soldiers
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func effect_20151_3():
	var targetId = get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var targetActor = ActorHelper.actor(targetId)

	var ap = int(me.action_point / 2)
	var soldiers = int(actor.get_soldiers() / 2)
	soldiers = min(soldiers, 2500 - targetActor.get_soldiers())
	soldiers = max(0, soldiers)

	ske.cost_war_cd(1)
	ske.cost_ap(ap, true)
	ske.change_actor_ap(targetId, ap)
	ske.cost_self_soldiers(soldiers)
	ske.change_actor_soldiers(targetId, soldiers)
	ske.war_report()

	var msg = "皆为王事，岂有彼此\n以吾有余，补君不足"
	FlowManager.add_flow("draw_actors")
	play_dialog(me.actorId, msg, 2, 2009)
	return
