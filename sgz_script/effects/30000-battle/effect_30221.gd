extends "effect_30000.gd"

#破发效果
#【破发】小战场，锁定技。对方使用战术后，对方的战术值清零。
#【创止】大战场，锁定技。你视为拥有<识策>和<破发>

func on_trigger_30018()->bool:
	if enemy == null:
		return false
	ske.battle_change_tactic_point(-enemy.battle_tactic_point, enemy)
	ske.battle_report()

	var msg = "{0}技止于此尔！\n（【{1}】发动\n（{2}战术值归零".format([
		DataManager.get_actor_naughty_title(enemy.actorId, actorId),
		ske.skill_name, enemy.get_name(),
	])
	me.attach_free_dialog(msg, 0, 30000)
	return false
