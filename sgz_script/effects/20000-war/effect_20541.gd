extends "effect_20000.gd"

#据义锁定技
#【据义】大战场，锁定技。你占据大义，敌方回合结束时，敌方士兵遭受良心谴责，自发逃离军队，每名敌将下降(X*20)的兵力（X=敌将进行攻击宣言的次数）。 —— 因为是逃离的，所以没有经验

func on_trigger_20016() -> bool:
	# 只针对敌方主将触发一次
	if ske.actorId != me.get_enemy_leader().actorId:
		return false
	var wf = DataManager.get_current_war_fight()

	var runaway = 0
	for wa in me.get_enemy_war_actors(true):
		var x = wa.get_day_attacked_actors(wf.date).size()
		if x > 0:
			runaway += ske.change_actor_soldiers(wa.actorId, -x * 20)
	if runaway == 0:
		return false

	ske.war_report()

	var msg = "汝众皆食汉禄\n何以从贼作乱？"
	me.attach_free_dialog(msg, 0)
	var enemyLeader = me.get_enemy_leader()
	msg = "军心浮动\n士兵逃散 {0} 人".format([abs(runaway)])
	me.attach_free_dialog(msg, 3, 20000, enemyLeader.actorId)
	return false
