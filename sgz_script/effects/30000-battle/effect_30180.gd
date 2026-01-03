extends "effect_30000.gd"

#莽骑小战场效果 
#【莽骑】小战场，锁定技。你默认2步8骑。

func on_trigger_30003()->bool:
	bf.update_extra_formation_setting(
		actorId, ske.skill_name, "常规", {
			"兵种数量": {"步":2,"骑":8},
			"分配顺序": ["步", "骑"],
		}
	)
	return false
