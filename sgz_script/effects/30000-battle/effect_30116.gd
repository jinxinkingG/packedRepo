extends "effect_30000.gd"

#统胜锁定技
#【统胜】小战场,锁定技。你的统＞对方时，你方士气+8。

func on_trigger_30005():
	if me.battle_lead <= enemy.battle_lead:
		return false
	ske.battle_change_morale(8, me)
	ske.battle_report()
	return false
