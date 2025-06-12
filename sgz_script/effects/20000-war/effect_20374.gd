extends "effect_20000.gd"

#慎行效果实现
#【慎行】大战场，锁定技。你移动每一步所消耗的机动力+1；你用任意计策所需的机动力-1。

func on_trigger_20005()->bool:
	var cost = get_env_int("计策.消耗.所需")
	cost = max(3, cost - 1)
	set_scheme_ap_cost("ALL", cost)
	return false

func on_trigger_20004()->bool:
	var schemes = get_env_array("战争.计策列表")
	var msg = get_env_str("战争.计策提示")
	for scheme in schemes:
		var cost = int(scheme[1])
		scheme[1] = max(3, cost - 1)
	change_stratagem_list(me.actorId, schemes, msg)
	return false

func on_trigger_20007()->bool:
	reduce_move_ap_cost([], -1)
	return false

