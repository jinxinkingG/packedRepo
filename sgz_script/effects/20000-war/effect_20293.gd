extends "effect_20000.gd"

#镇围限定技 #施加状态 #全体
#【镇围】大战场，主将限定技。使用后，对方全体武将附加1回合“围困”。（围困：负面状态，你无法大战场撤退，且无法主动回营地。）

const EFFECT_ID = 20293
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation()
	return

func effect_20293_start():
	var msg = "发动【{0}】\n本回合内敌军全体\n将被[围困]，可否？".format([
		ske.skill_name,
	])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func effect_20293_2():

	ske.cost_war_cd(99999)
	var leaderName = "敌将"
	var wv = me.war_vstate()
	var enemyWV = wv.get_enemy_vstate()
	if enemyWV != null:
		var enemyLeader = DataManager.get_war_actor(enemyWV.main_actorId)
		if enemyLeader != null:
			leaderName = enemyLeader.get_name()
	for targetId in get_enemy_targets(me, true, 999):
		ske.set_war_buff(targetId, "围困", 2)
	var msg = "{0}休走！\n今日既决胜负，亦决生死！".format([
		leaderName,
	])
	# 仅记录日志
	ske.war_report()
	play_dialog(me.actorId, msg, 0, 2001)
	return
