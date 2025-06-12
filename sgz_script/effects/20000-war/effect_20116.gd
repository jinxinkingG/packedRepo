extends "effect_20000.gd"

#越岭大战场效果
#【越岭】大战场&小战场,锁定技。你移动经过山地形时，每步消耗的机动力不超过3。你在山地形进入白兵时，视为山军。

func check_trigger_correct()->bool:
	set_max_move_ap_cost(["山地"], 3)
	return false
