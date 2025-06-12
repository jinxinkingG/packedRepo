extends "effect_20000.gd"

#翻山大战场效果
#【翻山】大战场,锁定技。你经过山地形时，消耗的机动力-1，且至少为1。

func check_trigger_correct()->bool:
	reduce_move_ap_cost(["山地"], 1)
	return false
