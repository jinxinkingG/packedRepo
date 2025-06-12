extends "effect_20000.gd"

#穿林大战场效果
#【穿林】大战场&小战场,锁定技。你移动经过林地形时，每步消耗的机动力不超过3。你在林地形进入白兵时，视为平军。

func check_trigger_correct()->bool:
	set_max_move_ap_cost(["树林"], 3)
	return false

