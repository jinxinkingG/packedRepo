extends "effect_20000.gd"

# 透阵被动效果部分
#【透阵】大战场，主动技。相邻敌军若可后退，且你可移动到其后退位置，你可消耗5机动力，对其发起攻击。若攻击获胜，视为成功突破敌阵，你体力+15，并移动到其后退位置，敌军原地不动。

const RECOVER_HP = 15

func on_trigger_20020() -> bool:
	var bf = DataManager.get_current_battle_fight()
	if bf.source != ske.skill_name:
		return false
	if bf.get_attacker_id() != actorId:
		return false
	var winner = bf.get_winner()
	if winner == null:
		return false
	if winner.actorId != actorId:
		return false
	var loser = bf.get_loser()
	if loser == null:
		return false
	var current = me.position
	var pos = bf.get_position()
	var recover = ske.change_actor_hp(actorId, RECOVER_HP)
	if Global.get_distance(pos, current) != 1:
		return false
	var msg = ""
	if loser.disabled:
		ske.change_war_actor_position(actorId, pos * 2 - current)
		msg = "全灭{0}所部！".format([
			loser.get_name(),
		])
	else:
		ske.change_war_actor_position(loser.actorId, pos)
		ske.change_war_actor_position(actorId, pos * 2 - current)
		ske.war_report()
		msg = "透阵而过，{0}岂能阻我！".format([
			loser.get_name(),
		])
	if msg != "":
		if recover > 0:
			msg += "\n（{0}体力回复 {1}".format([
				actor.get_name(), recover,
			])
		me.attach_free_dialog(msg, 0)
	ske.war_report()
	return false
