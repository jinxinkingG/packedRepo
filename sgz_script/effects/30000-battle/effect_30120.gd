extends "effect_30000.gd"

#城御锁定技 #士气
#【城御】小战场,锁定技。小战场，锁定技。你为城地形守方时，对方士气-5

func on_trigger_30005():
	ske.battle_change_morale(-5, enemy)
	ske.battle_report()
	return false
