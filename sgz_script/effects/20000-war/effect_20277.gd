extends "effect_20000.gd"

#胜志效果
#【胜志】大战场，锁定技。你作为攻方白刃战胜利时，你的体力+10，至多回复至上限。每日限一次

func on_trigger_20020()->bool:
	var bf = DataManager.get_current_battle_fight()
	if me == null or me.disabled:
		return false
	var loser = bf.get_loser()
	if loser == null:
		return false
	var winner = loser.get_battle_enemy_war_actor()
	if winner == null or winner.actorId != me.actorId:
		# 不是胜利方
		return false
	if me.actorId != bf.get_attacker_id():
		# 不是攻方
		return false

	var recover = ske.change_actor_hp(me.actorId, 10)
	if recover == 0:
		return false
	ske.cost_war_cd(1)
	ske.war_report()

	var msg = "克敌制胜，足以忘却伤痛！\n（因【{0}】作用，{1}体力恢复至{2}".format([
		ske.skill_name, actor.get_name(), int(actor.get_hp()),
	])
	me.attach_free_dialog(msg, 1)
	return false
