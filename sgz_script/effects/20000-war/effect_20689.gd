extends "effect_20000.gd"

# 寻洲效果
#【寻洲】大战场，锁定技。你在建安、夷洲大战场移动时，消耗机动力-2，但至少需1点。

const TARGET_CITY_IDS = [37, 39]

func on_trigger_20007()->bool:
	if not wf.target_city().ID in TARGET_CITY_IDS:
		return false
	reduce_move_ap_cost([], 2)
	return false

