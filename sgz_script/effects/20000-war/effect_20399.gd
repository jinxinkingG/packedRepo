extends "effect_20000.gd"

#速进被动效果
#【速进】大战场，主动技。你方米减5%，回合结束前，你移动一步所需机动力-1，且至少为1。每3回合限1次。

const PASSIVE_EFFECT_ID = 20398

func on_trigger_20007()->bool:
	if ske.get_war_skill_val_int(PASSIVE_EFFECT_ID) <= 0:
		return false
	reduce_move_ap_cost([], 1)
	return false
