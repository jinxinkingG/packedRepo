extends "effect_20000.gd"

#居奇被动触发判断
#【居奇】大战场，锁定技。回合结束时，若你方金<2000，金+X，X=（你点数+等级）*2。

func on_trigger_20016()->bool:
	var wv = me.war_vstate()
	if wv == null:
		return false
	if wv.money >= 2000:
		return false
	var strange = (actor.get_level() + me.poker_point) * 2
	ske.change_wv_gold(strange)
	ske.war_report()
	return false
