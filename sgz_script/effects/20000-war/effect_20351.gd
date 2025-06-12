extends "effect_20000.gd"

#酒步锁定技 #移动
#【酒步】大战场，锁定技。你移动每一步消耗的机动力都在[1，X]中随机取值（X=原本移动至目标格所需的机动力）。

func on_trigger_20007()->bool:
	var ap = DataManager.get_env_int(KEY_MOVE_AP_COST)
	if ap <= 1:
		return false
	var reduce = DataManager.pseduo_random_war() % ap
	if reduce == 0:
		return false
	reduce_move_ap_cost([], reduce)
	return false
