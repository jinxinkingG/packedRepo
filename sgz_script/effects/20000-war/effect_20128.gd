extends "effect_20000.gd"

#智神效果实现
#【智神】大战场,锁定技。你使用计策消耗的机动力为原来的2/3，向下取整

func on_trigger_20005()->bool:
	var cost = get_env_int("计策.消耗.所需")
	cost = max(3, int(cost * 2 / 3))
	set_scheme_ap_cost("ALL", cost)
	return false
