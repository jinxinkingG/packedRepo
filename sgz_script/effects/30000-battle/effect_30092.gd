extends "effect_30000.gd"

#势威技能实现
#【势威】小战场,锁定技。你为攻方时，你方士气+5，战术值+3，对方士气-5，战术值-3。

func on_trigger_30005()->bool:
	ske.battle_change_morale(5)
	ske.battle_change_tactic_point(3)
	ske.battle_change_morale(-5, enemy)
	ske.battle_change_tactic_point(-3, enemy)
	ske.battle_report()

	var msg = "兵锋所至，其谁能敌？\n（{0}发动【{1}】".format([
		me.get_name(), ske.skill_name
	])
	append_free_dialog(me, msg, 0)
	return false
