extends "effect_20000.gd"

#滞锁主动技 #施加状态
#【滞锁】大战场,主动技。你可以选定一个知比你小的对方武将，消耗5点机动力，对其附加一回合 {迟滞}。每个回合限1次。可对城地形目标发动。

const EFFECT_ID = 20230
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 5
const BUFF_NAME = "迟滞"

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_4")
	return

func effect_20230_start():
	if not assert_action_point(me.actorId, COST_AP):
		return

	var targets = []
	for targetId in get_enemy_targets(me, true):
		if ActorHelper.actor(targetId).get_wisdom() >= actor.get_wisdom():
			continue
		var wa = DataManager.get_war_actor(targetId)
		if wa.get_buff(BUFF_NAME)["回合数"] > 0:
			continue
		targets.append(targetId)
	if not wait_choose_actors(targets, "选择敌军发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20230_2():
	var targetId = get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var targetActor = ActorHelper.actor(targetId)

	var msg = "消耗{0}机动力\n对{1}发动【{2}】\n可否？".format([
		COST_AP, targetActor.get_name(), ske.skill_name,
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func effect_20230_3():
	var targetId = get_env_int("目标")

	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	ske.set_war_buff(targetId, BUFF_NAME, 1)
	var msg = "多设疑兵，{0}必不敢速进".format([
		DataManager.get_actor_naughty_title(targetId, ske.skill_actorId),
	])
	report_skill_result_message(ske, 2002, msg, 2)
	return

func effect_20230_4():
	report_skill_result_message(ske, 2002)
	return
