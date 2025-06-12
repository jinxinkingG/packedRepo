extends "effect_30000.gd"

#狭威小战场效果
#【狭威】大战场，主动技。你可消耗任意点数的机动力发动。将消耗的机动力转为等量的“威”标记；你每有一个“威”标记，白刃战时你的士气 +1，最大升至70；你方回合开始时，清空你的“威”标记。每回合限-次。

const FLAG_EFFECT_ID = 20495
const FLAG_NAME = "威"

func on_trigger_30005()->bool:
	var x = 70 - me.battle_morale
	x = min(x, ske.get_skill_flags(20000, FLAG_EFFECT_ID, FLAG_NAME))
	if x <= 0:
		return false
	ske.battle_change_morale(x)
	ske.battle_report()
	return false
