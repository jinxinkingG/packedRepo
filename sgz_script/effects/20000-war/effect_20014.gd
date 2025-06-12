extends "effect_20000.gd"

#锦帆：河流地形，移动消耗机动力-1

func check_trigger_correct()->bool:
	reduce_move_ap_cost(["河流"], 1)
	return false
