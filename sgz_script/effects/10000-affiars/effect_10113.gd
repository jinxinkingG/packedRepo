extends "effect_10000.gd"

#备战主动技
#【政能】内政，主动技。每过1月，你增加1个“能”标记，最多累积12个。你可消耗3个[能]标记，主动发动此技能：令你方势力命令书+1。每月限1次。

const EFFECT_ID = 10113
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const FLAG_NAME = "能"
const COST_FLAGS = 3

func effect_10113_start()->void:
	var x = ske.get_skill_flags(10000, EFFECT_ID, FLAG_NAME)
	if x < COST_FLAGS:
		var msg = "[{0}]不足，还当厚积薄发".format([FLAG_NAME])
		play_dialog(actorId, msg, 3, 2999)
		return

	ske.cost_skill_flags(10000, EFFECT_ID, FLAG_NAME, COST_FLAGS)
	ske.affair_cd(1)

	DataManager.orderbook += 1
	SceneManager.actor_dialog.conOrderbook.update_orderbook()

	var msg = "政预则立，不预则废\n（命令书 +1"
	play_dialog(actorId, msg, 1, 2999)
	return
