extends "effect_20000.gd"

#智神效果实现
#【智神】大战场,锁定技。你使用计策消耗的机动力为原来的2/3，向下取整

func on_trigger_20005()->bool:
	var settings = DataManager.get_env_dict("计策.消耗")
	var name = settings["计策"]
	var cost = int(settings["所需"])
	cost = max(3, int(cost * 2 / 3))
	reduce_scheme_ap_cost(name, cost)
	return false
