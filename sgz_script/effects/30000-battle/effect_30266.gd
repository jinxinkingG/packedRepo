extends "effect_30000.gd"

#政守效果
#【政守】小战场,锁定技。你为白刃战守方，若你的政＞对方时，对方士气-6，你的士气+6。

func on_trigger_30005():
	if me == null or enemy == null:
		return false
	if actor.get_politics() <= enemyActor.get_politics():
		return false
	ske.battle_change_morale(6, me)
	ske.battle_change_morale(-6, enemy)
	ske.battle_report()
	return false
