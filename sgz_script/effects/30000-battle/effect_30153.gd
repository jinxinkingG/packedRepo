extends "effect_30000.gd"

#焚射锁定技
#【焚射】小战场,锁定技。你使用[火矢]默认消耗5点战术值。

func on_trigger_30005():
	me.dic_other_variable["火矢额外消耗"] = -5
	return false
