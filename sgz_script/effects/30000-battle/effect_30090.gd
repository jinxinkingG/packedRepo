extends "effect_30000.gd"

#越岭小战场效果 #临时军种
#【越岭】大战场&小战场,锁定技。你移动经过山地形时，每步消耗的机动力不超过3。你在山地形进入白兵时，视为山军。

func on_trigger_30005()->bool:
	me.dic_other_variable["临时军种"] = "山"
	return false

func on_trigger_30099()->bool:
	me.dic_other_variable.erase("临时军种")
	return false
