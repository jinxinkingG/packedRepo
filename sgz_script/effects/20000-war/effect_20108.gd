extends "effect_20000.gd"

#藤筏效果实现
#【藤筏】大战场,锁定技。你经过水地形时，固定消耗1点机动力。

func check_trigger_correct()->bool:
	set_max_move_ap_cost(["河流"], 1)
	return false

