extends "effect_20000.gd"

#远檄效果
#【远檄】大战场，锁定技。你使用计策距离+1，计算命中率时距离-1。

func on_trigger_20026() -> bool:
	DataManager.set_env("计策.ONCE.距离", {"ALL": {
		"范围修正": 1,
		"距离修正": -1,
	}})
	return false
