extends "effect_20000.gd"

#锋略效果
#【锋略】大战场，锁定技。若你使用伤兵计成功，那次伤害增加X倍。X=你的点数*0.1。

func on_trigger_20011()->bool:
	if me.poker_point <= 0:
		return false
	change_scheme_damage_rate(me.poker_point * 10)
	return false
