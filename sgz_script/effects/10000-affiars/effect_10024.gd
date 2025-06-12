extends "effect_10000.gd"

#备战锁定效果
#【备战】内政,锁定技。每月你的永久标记[备]+100。你可以通过发动此技能将[备]转为等量的金。

const EFFECT_ID = 10024
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const FLAG_ID = 10025
const FLAG_NAME = "备"

func on_trigger_10001()->bool:
	ske.add_skill_flags(10000, FLAG_ID, FLAG_NAME, 100, 10000)
	return false

func on_trigger_20034():
	return on_trigger_10001()
