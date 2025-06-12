extends "effect_30000.gd"

#智扰锁定技
#【智扰】小战场，锁定技。战斗初始，若你知大于对方，则对方战术值-3。

func on_trigger_30005()->bool:
	var enemy = me.get_battle_enemy_war_actor()
	if enemy == null:
		return false

	if me.actor().get_wisdom() <= enemy.actor().get_wisdom():
		return false

	ske.battle_change_tactic_point(-3, enemy)
	ske.battle_report()
	var msg = "可笑{0}小儿\n智之不足，何以驭阵？\n（{0}战术值-3".format([
		enemy.get_name(),
	])
	append_free_dialog(me, msg, 1)
	return false
