extends "effect_20000.gd"

#巧变效果实现
#【巧变】大战场,锁定技。若你拥有负面状态，移动时所需的机动力下降1半。你不会因负面状态而「禁止移动」。

func on_trigger_20013()->bool:
	me.set_tmp_variable("无视定止", 1)
	return false

func on_trigger_20007()->bool:
	if not me.is_war_debuffed():
		return false
	var cost = get_env_int(KEY_MOVE_AP_COST)
	set_max_move_ap_cost([], int(cost / 2))
	return false
