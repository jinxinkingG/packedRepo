extends "effect_20000.gd"

#慎稳锁定技
#【慎稳】大战场，锁定技。你的兵力＞1000时，你造成的计策伤害减半，你受到的计策伤害减半。

const DAMAGE_RATE_CHANGE = -50

func on_trigger_20011()->bool:
	half_damage()
	return false

func on_trigger_20002()->bool:
	half_damage()
	return false

func half_damage()->void:
	if actor.get_soldiers() <= 1000:
		return
	change_scheme_damage_rate(DAMAGE_RATE_CHANGE)
	return
