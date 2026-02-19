extends "effect_30000.gd"

#巨象效果实现
#【巨象】小战场，锁定技。你拥有 {象兵}。☆制作组全体提示：象兵不是骑兵，步兵骑兵技能对象兵一律无效，再问撞猪……。

func on_trigger_30033() -> bool:
	bf.update_extra_formation_setting(
		actorId, ske.skill_name, "特殊", {
			"兵种强转": {"骑": "象"},
		}
	)
	return false
