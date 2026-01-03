extends "effect_20000.gd"

#援主诱发计 #截击
#【援主】大战场,诱发技。你的方主将被计策伤兵的场合，你可以消耗5点机动力，向施计者发起白兵宣言，每回合限3次。

const EFFECT_ID = 20144
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 5
const TIMES_LIMIT = 3

func on_trigger_20012()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	if se.succeeded <= 0:
		return false
	var leaderId = me.get_main_actor_id()
	if leaderId != se.targetId:
		return false
	if leaderId == me.actorId:
		# 自身被用计，不可发动
		return false
	var fromId = se.get_action_id(actorId)
	if fromId < 0:
		return false
	if check_combat_targets([fromId]).empty():
		# 不可以被技能发起白刃战
		return false
	var fromWarActor = DataManager.get_war_actor(fromId)
	if fromWarActor == null or fromWarActor.disabled:
		return false
	if se.get_soldier_damage_for(leaderId) <= 0:
		return false

	# 每回合限三次
	if ske.get_war_limited_times() >= TIMES_LIMIT:
		return false

	if me.action_point < COST_AP:
		return false

	return true


func effect_20144_AI_start():
	goto_step("2")
	return

func effect_20144_start():
	var se = DataManager.get_current_stratagem_execution()
	var fromId = se.get_action_id(me.actorId)
	var msg = "消耗{0}机动力，发动【{1}】\n攻击用计者{2}\n可否？".format([
		COST_AP, ske.skill_name,
		ActorHelper.actor(fromId).get_name()
	])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2", false)
	return

func effect_20144_2():
	var se = DataManager.get_current_stratagem_execution()
	var leaderId = me.get_main_actor_id()
	var fromId = se.get_action_id(me.actorId)

	var msg = "{0}勿忧\n吾当急袭{1}\n（{2}发动【{3}】".format([
		DataManager.get_actor_honored_title(leaderId, me.actorId),
		ActorHelper.actor(fromId).get_name(), me.get_name(),
		ske.skill_name,
	])
	play_dialog(me.actorId, msg, 2, 2001)
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20144_3():
	var se = DataManager.get_current_stratagem_execution()
	var fromId = se.get_action_id(me.actorId)
	ske.cost_war_limited_times(TIMES_LIMIT)
	ske.cost_ap(COST_AP)
	ske.war_report()
	# SE-TODO
	# 暂时手动处理日志和 flow，未来通过 BattleExecution 解决
	se.report()
	start_battle_and_finish(me.actorId, fromId)
	return

