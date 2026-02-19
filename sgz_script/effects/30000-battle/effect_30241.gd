extends "effect_30000.gd"

#骉枪锁定技
#【骉枪】小战场，锁定技。你默认7步3骑。你方步兵攻击方式：1格，正常近战攻击；2~3格，“投掷标枪”，基础伤害倍率1.0。注：2~3格的投掷标枪，不触发近战附加的效果。

func on_trigger_30003()->bool:
	bf.update_extra_formation_setting(
		actorId, ske.skill_name, "常规", {
			"兵种数量": {"步":7,"骑":3},
			"分配顺序": ["步", "骑"],
		}
	)
	return false

func on_trigger_30024()->bool:
	var unitId = DataManager.get_env_int("白兵.初始化单位ID")
	var bu = bf.battle_unit(unitId)
	if bu == null or bu.disabled:
		return false
	if bu.Type == "步":
		bu.reset_type("步(标枪)")
		bu.set_combat_val("投掷类型", 2, ske.skill_name)
	return false
