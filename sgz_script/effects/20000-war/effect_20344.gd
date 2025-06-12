extends "effect_20000.gd"

#互援主动技
#【互援】大战场，主动技。你可以消耗5点机动力，指定一个己方武将，将你二人的兵力汇总平分。每2回合限1次

const EFFECT_ID = 20344
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 5
const COST_CD = 2

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
func effect_20344_start():
	if not assert_action_point(me.actorId, COST_AP):
		return
	var targets = []
	for targetId in get_teammate_targets(me):
		var targetActor = ActorHelper.actor(targetId)
		if targetActor.get_soldiers() == actor.get_soldiers():
			continue
		targets.append(targetId)
	if targets.empty():
		play_dialog(me.actorId, "没有合适的目标", 2, 2009)
		return
	if not wait_choose_actors(targets, "选择队友发动【互援】"):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20344_2():
	var targetId = get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)

	var total = targetActor.get_soldiers() + actor.get_soldiers()
	var soldiers = int(total / 2)
	var msg = "消耗{0}机动力发动【互援】\n与{1}平分兵力\n可否？".format([
		COST_AP, targetActor.get_name(),
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func effect_20344_3():
	var targetId = get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)

	# 谁占便宜了？
	var helping = true
	if targetActor.get_soldiers() > actor.get_soldiers():
		helping = false
	ske.cost_war_cd(COST_CD)
	ske.cost_ap(COST_AP, true)
	var total = targetActor.get_soldiers() + actor.get_soldiers()
	var soldiers = int(total / 2)
	ske.change_actor_soldiers(me.actorId, soldiers - actor.get_soldiers())
	ske.change_actor_soldiers(targetId, total - soldiers - targetActor.get_soldiers())
	ske.war_report()

	var msg = "守望相助，应有之义\n{0}不必为念\n（二人均分兵力"
	if not helping:
		msg = "今有急难，惟君可解\n多谢{0}援手\n（二人均分兵力"
	msg = msg.format([
		DataManager.get_actor_honored_title(targetId, self.actorId),
	])
	FlowManager.add_flow("draw_actors")
	play_dialog(me.actorId, msg, 2, 2009)
	return
