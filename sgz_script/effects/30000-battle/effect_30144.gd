extends "effect_30000.gd"

#政攻效果
#【政攻】小战场,锁定技。若你为攻方，对方政小于你时：若你的士气＜45，则附加到45；若你的士气不小于45，则你的士气+5

func on_trigger_30005():
	if me == null or enemy == null:
		return false
	if actor.get_politics() <= enemyActor.get_politics():
		return false
	if me.battle_morale < 45:
		ske.battle_change_morale(45 - me.battle_morale)
	else:
		ske.battle_change_morale(5)
	ske.battle_report()
	return false
