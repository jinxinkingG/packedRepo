extends "effect_20000.gd"

#儒帅主动技部分
#【儒帅】大战场，主将主动技。你可以消耗10点机动力，指定一个己方武将，令其机动力+6，并记录该武将所在格。本回合结束后，若记录格为空，则该武将回到记录格，每个回合限1次。

const EFFECT_ID = 20285
const PASSIVE_EFFECT_ID = 20286
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 10
const BUFF_AP = 6

func effect_20285_start():
	if not assert_action_point(actorId, COST_AP):
		return
	if not wait_choose_actors(get_teammate_targets(me), "选择队友发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20285_2():
	var targetId = DataManager.get_env_int("目标")
	var msg = "消耗{0}机动力\n发动【{1}】\n标记{2}位置，可否？".format([
		COST_AP, ske.skill_name, ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20285_3():
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	if BUFF_AP > 0:
		ske.change_actor_ap(targetId, BUFF_AP)
	var val = "{0}|{1}|{2}".format([
		targetId, targetWA.position.x, targetWA.position.y
	])
	ske.set_war_skill_val(val, 1, PASSIVE_EFFECT_ID)
	ske.set_war_skill_val(targetId, 1)
	ske.war_report()

	var msg = "{0}放心冲阵杀敌\n归路我已部署妥当".format([
		DataManager.get_actor_honored_title(targetId, actorId),
	])
	if BUFF_AP > 0:
		msg += "\n（{0}机动力 +{1}".format([
			ActorHelper.actor(targetId).get_name(),
			BUFF_AP
		])
	play_dialog(actorId, msg, 1, 2999)
	return
