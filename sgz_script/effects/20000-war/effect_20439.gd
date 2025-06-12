extends "effect_20000.gd"

#诚济主动技
#【诚济】大战场，主动技。你可以指定一个己方武将，令其机动力+4，每个回合限1次。

const EFFECT_ID = 20439
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const GRANT_AP = 4
const COST_CD = 1

# 发动主动技
func effect_20439_start():
	var targets = get_teammate_targets(me)
	if targets.empty():
		play_dialog(me.actorId, "没有合适的目标", 2, 2999)
		return
	if not wait_choose_actors(targets, "选择队友发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20439_2():
	var targetId = DataManager.get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)

	var msg = "对{0}发动【{1}】\n令其机动力+{2}\n可否？".format([
		targetActor.get_name(), ske.skill_name, GRANT_AP,
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20439_3():
	var targetId = DataManager.get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)

	# 谁占便宜了？
	ske.cost_war_cd(COST_CD)
	ske.change_actor_ap(targetId, GRANT_AP)
	ske.war_report()

	var msg = "吾非驱使足下\n诚心相助尔\n（{0}机动力+{1}".format([
		targetActor.get_name(), GRANT_AP
	])
	play_dialog(me.actorId, msg, 2, 2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return
