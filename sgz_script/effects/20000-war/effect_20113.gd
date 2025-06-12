extends "effect_20000.gd"

#焚粮诱发技 #胜利触发
#【焚粮】大战场,诱发技。金＞100时，我方其他武将白兵进攻胜利的场合，你可以消耗3点机动力，20金，无视距离对对方主将发动一次必中的[火箭]。每回合限一次

const EFFECT_ID = 20113
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const STRATAGEM = "火箭"
const COST_AP = 3
const COST_GOLD = 20
const REQUIRED_GOLD = 100

func on_trigger_20020()->bool:
	var bf = DataManager.get_current_battle_fight()
	if me == null or me.disabled:
		return false
	var loser = bf.get_loser()
	if loser == null:
		return false
	var winner = loser.get_battle_enemy_war_actor()
	if winner == null or not me.is_teammate(winner):
		# 不是胜利方
		return false
	if winner.actorId != bf.get_attacker_id():
		# 不是攻方
		return false
	if winner.actorId == me.actorId:
		# 胜利者是我自己
		return false

	var wv = me.war_vstate()
	if wv.money <= REQUIRED_GOLD:
		# 金不足
		return false

	var enemyLeader = me.get_enemy_leader()
	if enemyLeader == null or enemyLeader.disabled:
		return false

	if me.action_point < COST_AP:
		# 机动力不足
		return false

	return true

func effect_20113_AI_start():
	goto_step("2")
	return

func effect_20113_start():
	var msg = "消耗 {0} 金、{1} 机动力\n发动【{2}】，可否？".format([
		COST_GOLD, COST_AP, ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000()->void:
	wait_for_yesno(FLOW_BASE + "_2", false)
	return

func effect_20113_2():
	ske.cost_wv_gold(COST_GOLD)
	ske.cost_ap(COST_AP)
	ske.war_report()

	# 无视距离对敌主将发动火箭
	var se = DataManager.new_stratagem_execution(me.actorId, STRATAGEM, ske.skill_name)
	se.set_target(me.get_enemy_leader().actorId)
	se.perform_to_targets([se.targetId], true)

	var msg = "敌军败相已彰\n烧其粮草，阵脚必乱"
	ske.play_se_animation(se, 2001, msg, 0)
	return

func on_view_model_2001()->void:
	wait_for_pending_message(FLOW_BASE + "_report", "")
	return

func effect_20113_report():
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 2001)
	return
