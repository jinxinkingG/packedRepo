extends "effect_30000.gd"

#巨象效果实现
#【巨象】小战场,锁定技。你拥有象兵。象兵：基础减伤倍率0.65，基础伤害倍率2.2，小战场，每轮初始时，象兵hp低于100，则该轮可2动；低于50，该轮3动。

func on_trigger_30033() -> bool:
	bf.update_extra_formation_setting(
		actorId, ske.skill_name, "特殊", {
			"兵种强转": {"骑": "象"},
		}
	)
	return false
