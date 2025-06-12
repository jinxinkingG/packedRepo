extends "effect_10000.gd"

# 政能锁定效果
#【政能】内政，主动技。每过1月，你增加1个“能”标记，最多累积12个。你可消耗3个[能]标记，主动发动此技能：令你方势力命令书+1。每月限1次。

const EFFECT_ID = 10112
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const FLAG_ID = 10113
const FLAG_NAME = "能"

func on_trigger_10001()->bool:
	ske.add_skill_flags(10000, FLAG_ID, FLAG_NAME, 1, 12)
	return false
