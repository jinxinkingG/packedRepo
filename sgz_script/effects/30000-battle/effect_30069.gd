extends "effect_30000.gd"

#至武技能实现
#【至武】小战场,锁定技。白兵你为攻方时，你方初始士气+x，对方初始士气-x，x＝你的等级+1。

func on_trigger_30005():
	var x = actor.get_level() + 1

	ske.battle_change_morale(x, me)
	ske.battle_change_morale(-x, enemy)
	ske.battle_report()

	return false
