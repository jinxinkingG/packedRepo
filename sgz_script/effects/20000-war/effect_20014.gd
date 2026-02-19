extends "effect_20000.gd"

# 锦帆锁定效果
#【锦帆】大战场，锁定技。你在河流地形中，移动消耗的机动力-1（至少剩1）。

func check_trigger_correct()->bool:
	reduce_move_ap_cost(["河流"], 1)
	return false
