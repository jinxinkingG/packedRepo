extends "effect_20000.gd"

#直言主动技
#【直言】大战场，主动技。你可指定一个友军武将，消耗X点机动力：令其五行刷新，且点数为x，同时使其下一次白刃战战术值+x。x=你的等级。而后你获得2回合｛迟滞｝。每回合限1次。

const EFFECT_ID = 20516
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20516_start():
	var x = actor.get_level()
	if not assert_action_point(actorId, x):
		return
	if not wait_choose_actors(get_teammate_targets(me)):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20516_2():
	var targetId = DataManager.get_env_int("目标")
	var x = actor.get_level()
	var msg = "消耗{0}机动力\n对{1}发动【{2}】\n可否？".format([
		x, ActorHelper.actor(targetId).get_name(), ske.skill_name,
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20516_3():
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var x = actor.get_level()

	ske.cost_war_cd(1)
	ske.cost_ap(x, true)
	ske.set_war_skill_val([x, actorId], 1, -1, targetId)
	ske.change_actor_five_phases(targetId, -1, x)
	ske.set_war_buff(actorId, "迟滞", 2)
	ske.war_report()

	var msg = "亮直尽言，臣之道也"
	report_skill_result_message(ske, 2002, msg)
	return

func on_view_model_2002()->void:
	wait_for_pending_message(FLOW_BASE + "_4")
	return

func effect_20516_4():
	report_skill_result_message(ske, 2002)
	return
