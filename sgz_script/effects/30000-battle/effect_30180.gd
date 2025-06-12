extends "effect_30000.gd"

#莽骑小战场效果 
#【莽骑】小战场，锁定技。你默认2步8骑。

func on_trigger_30003()->bool:
	var formationKey = "白兵.阵型优先.{0}".format([me.actorId])
	if get_env_int(formationKey) > 1:
		return false
	set_env("兵种数量", {"步":2,"骑":8})
	set_env("分配顺序", ["步","骑"])
	set_env(formationKey, 1)
	return false
