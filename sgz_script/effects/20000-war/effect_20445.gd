extends "effect_20000.gd"

#鼓书主动技
#【鼓书】大战场，主动技。指定1名武将为目标，消耗你5点机动力才能发动。目标武将点数变为9点，其余在场武将点数变为1点。每3个回合限1次。

const EFFECT_ID = 20445
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 5

func effect_20445_start():
	if not assert_action_point(actorId, COST_AP):
		return
	var targets = get_teammate_targets(me)
	targets.append_array(get_enemy_targets(me))
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20445_2():
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var msg = "消耗{0}机动力，发动【{1}】\n令双方武将点数均为1\n{2}点数为9，可否？".format([
		COST_AP, ske.skill_name, targetWA.get_name()
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20445_3():
	var targetId = DataManager.get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)

	ske.cost_ap(COST_AP)
	ske.cost_war_cd(3)
	for wa in wf.get_war_actors(false):
		var point = 1
		if wa.actorId == targetId:
			point = 9
		ske.change_actor_five_phases(wa.actorId, wa.five_phases, point)
	ske.war_report()
	var msg = "{0}大儿，强可与语\n余子木梗泥偶，酒瓮饭囊耳".format([
		targetActor.get_name(),
	])
	play_dialog(actorId, msg, 1, 2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return
