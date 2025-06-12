extends "effect_30000.gd"

#慎骑效果 #阵型
#【慎骑】小战场，锁定技。你默认7骑3弓。

func on_trigger_30003()->bool:
	var formationKey = "白兵.阵型优先.{0}".format([me.actorId])
	if get_env_int(formationKey) > 1:
		return false
	set_env("兵种数量", {"弓":3,"骑":7})
	set_env("分配顺序", ["弓","骑"])
	set_env(formationKey, 1)
	return false
