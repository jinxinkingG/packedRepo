extends "effect_20000.gd"

#涉水大战场效果
#【涉水】大战场&小战场,锁定技。你移动经过水地形时，每步消耗的机动力不超过3，你在水地形进入白兵时，视为水军。

func check_trigger_correct()->bool:
	set_max_move_ap_cost(["河流"], 3)
	return false
