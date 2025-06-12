extends "effect_20000.gd"

#狭威被动效果
#【狭威】大战场，主动技。你可消耗任意点数的机动力发动。将消耗的机动力转为等量的“威”标记；你每有一个“威”标记，白刃战时你的士气 +1，最大升至70；你方回合开始时，清空你的“威”标记。每回合限-次。

const FLAG_EFFECT_ID = 20495
const FLAG_NAME = "威"

func on_trigger_20013()->bool:
	# 清除标记
	ske.clear_skill_flags(20000, FLAG_EFFECT_ID, FLAG_NAME)
	return false
