extends "effect_20000.gd"

#速进被动效果
#【速进】大战场，主动技。你方米减5%，回合结束前，你移动一步所需机动力-1，且至少为1。每3回合限1次。

const PASSIVE_EFFECT_ID = 20398  # 主动技效果ID

func on_trigger_20007() -> bool:
	# 检查是否有速进效果
	var speedEffect = ske.get_war_skill_val_int(PASSIVE_EFFECT_ID)
	if speedEffect <= 0:
		return false

	# 减少移动消耗（-1机动力）
	reduce_move_ap_cost([], 1)
	return false
