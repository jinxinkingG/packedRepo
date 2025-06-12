extends "effect_30000.gd"

#鼓气锁定技
#【鼓气】小战场，锁定技。白刃战初始，你方士气+你的点数。

func on_trigger_30005()->bool:
	ske.battle_change_morale(me.poker_point, me)
	ske.battle_report()
	return false
