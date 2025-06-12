extends "effect_30000.gd"

#忠勇技能实现
#【忠勇】小战场,锁定技。你的忠诚度 >=70 时，士气+x，武临时+x/2，x＝你的忠/12。

const FACTOR = 12

func on_trigger_30005():
	var loyalty = actor.get_loyalty()
	if loyalty < 70:
		return false

	var x = int(loyalty / FACTOR)
	ske.battle_change_power(int(x/2), me)
	ske.battle_change_morale(x, me)
	ske.battle_report()

	return false
