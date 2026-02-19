extends "effect_30000.gd"

#忠勇技能实现
#【忠勇】小战场，锁定技。若你忠＞=70时，你的士气+X，武临时+X/2，X＝你的忠/12。

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
