extends "effect_30000.gd"

#慎骑效果 #阵型
#【慎骑】小战场，锁定技。你默认7骑3弓。

func on_trigger_30003()->bool:
	bf.update_extra_formation_setting(
		actorId, ske.skill_name, "常规", {
			"兵种数量": {"弓":3, "骑":7},
			"分配顺序": ["弓", "骑"],
		}
	)
	return false
