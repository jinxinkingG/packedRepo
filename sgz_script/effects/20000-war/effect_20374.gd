extends "effect_20000.gd"

#慎行效果实现
#【慎行】大战场，锁定技。你移动每一步所消耗的机动力+1；你用任意计策所需的机动力-1。

func on_trigger_20005() -> bool:
	var settings = DataManager.get_env_dict("计策.消耗")
	var name = settings["计策"]
	var cost = int(settings["所需"])
	cost = max(3, cost - 1)
	reduce_scheme_ap_cost("ALL", cost)
	return false

func on_trigger_20007() -> bool:
	reduce_move_ap_cost([], -1)
	return false

