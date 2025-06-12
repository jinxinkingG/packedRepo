extends "effect_20000.gd"

#巡城效果实现
#【巡城】大战场,锁定技。你在城墙上移动时，消耗机动力-2。

func check_trigger_correct()->bool:
	reduce_move_ap_cost(["城墙"], 2)
	return false
