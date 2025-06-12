extends "effect_20000.gd"

#追袭诱发技 #进攻触发 #胜利触发 #追击
#【追袭】大战场,诱发技。你体力＞30，你为攻方，白兵胜利回到大战场的场合，你可以消耗5点体力，立即对该撤退武将发起白兵宣言。每回合限1次。

const EFFECT_ID = 20112
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_HP = 5

func on_trigger_20020()->bool:
	if me == null or me.disabled:
		return false
	var bf = DataManager.get_current_battle_fight()
	if bf.get_attacker_id() != actorId:
		# 不是攻方
		return false
	var loser = bf.get_loser()
	if loser == null or loser.disabled or me.is_teammate(loser):
		return false
	var winner = loser.get_battle_enemy_war_actor()
	if winner == null or winner.actorId != actorId:
		# 不是胜利方
		return false
	return me.actor().get_hp() > 30

func effect_20112_AI_start():
	goto_step("2")
	return

func effect_20112_start():
	var bf = DataManager.get_current_battle_fight()
	var msg = "消耗{0}体力\n对{1}发动【{2}】\n可否".format([
		COST_HP, bf.get_loser().get_name(), ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000()->void:
	wait_for_yesno(FLOW_BASE + "_2", false)
	return

func effect_20112_2():
	var bf = DataManager.get_current_battle_fight()
	var loser = bf.get_loser()

	var msg = "这点小伤何惧\n乘胜追击{0}！".format([
		DataManager.get_actor_naughty_title(loser.actorId, me.actorId)
	])
	play_dialog(actorId, msg, 0, 2001)
	map.next_shrink_actors = [me.actorId, loser.actorId]
	return

func on_view_model_2001()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20112_3():
	var bf = DataManager.get_current_battle_fight()

	ske.cost_war_cd(1)
	ske.cost_hp(COST_HP)
	ske.war_report()

	map.next_shrink_actors = []
	start_battle_and_finish(actorId, bf.get_loser().actorId)
	return
