extends "effect_30000.gd"

#飞羽小战场效果 
#【飞羽】小战场，锁定技。白刃战时，你的兵种变为全弓，生效一次后失去此技能。

func on_trigger_30003() -> bool:
	bf.update_extra_formation_setting(
		actorId, ske.skill_name, "常规", {
			"兵种数量": {"弓":10},
			"分配顺序": ["弓"],
			"信息": "全弓列阵",
			"大战场CD": [30175, 1, "飞羽"],
		}
	)
	return false
