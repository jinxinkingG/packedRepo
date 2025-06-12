extends "effect_30000.gd"

#坚守锁定技 #士气
#【坚守】小战场，锁定技。城类战斗中，若你为守方，你的士气恒定为99。

func on_trigger_30005()->bool:
	me.battle_morale = 99
	me.battle_morale_patched = 0
	me.dic_other_variable["固定士气"] = 99
	var msg = "背水一战，城在人在！"
	me.attach_free_dialog(msg, 0, 30000)
	return false

func on_trigger_30099()->bool:
	me.dic_other_variable.erase("固定士气")
	return false
