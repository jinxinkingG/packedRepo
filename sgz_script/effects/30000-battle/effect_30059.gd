extends "effect_30000.gd"

#德望技能实现
#【德望】小战场,锁定技。对方的“德”＜你时，对方士气-x，战术值-x/2，x＝你的等级。

func on_trigger_30005():
	if actor.get_moral() <= enemyActor.get_moral():
		return false

	var x = actor.get_level()
	ske.battle_change_morale(-x, enemy)
	ske.battle_change_tactic_point(-int(x/2), enemy)
	ske.battle_report()

	return false
