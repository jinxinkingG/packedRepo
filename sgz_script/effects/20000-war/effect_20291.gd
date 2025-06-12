extends "effect_20000.gd"

#连袭主动技实现
#【连袭】大战场，主动技。你可以指定一个对方武将，本回合结束前，你对其发起攻击宣言无需耗费机动力。每3个回合限一次。

const EFFECT_ID = 20291
const PASSIVE_EFFECT_ID = 20292
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation()
	return

func effect_20291_start():
	var msg = "选择敌军发动【{0}】".format([ske.skill_name])
	if not wait_choose_actors(get_enemy_targets(me), msg):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20291_2():
	var targetId = get_env_int("目标")
	var msg = "发动【{0}】，本回合内攻击{1}无须消耗机动力。可否？".format([
		ske.skill_name, ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func effect_20291_3():
	var targetId = get_env_int("目标")
	ske.cost_war_cd(3)
	ske.set_war_skill_val(targetId, 1, PASSIVE_EFFECT_ID)
	ske.war_report()

	var msg = "不灭{0}，誓不收兵！".format([
		ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(me.actorId, msg, 0, 2002)
	return
