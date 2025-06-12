extends "effect_20000.gd"

#疾行效果实现
#【疾行】大战场,锁定技。你花色为红色时，每移动一步所需的机动力-1，且消耗最少为1

func on_trigger_20007()->bool:
	match me.five_phases:
		War_Character.FivePhases_Enum.Wood:
			pass
		War_Character.FivePhases_Enum.Fire:
			pass
		_: # 非红色跳过
			return false
	reduce_move_ap_cost([], 1)
	return false

