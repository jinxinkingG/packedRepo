extends "effect_20000.gd"


#马术
#【马术】大战场,锁定技。你在平地或者沙漠地形时，移动消耗的机动力-1（至少剩1）。

func check_trigger_correct()->bool:
	reduce_move_ap_cost(["平原", "沙漠"], 1)
	return false
