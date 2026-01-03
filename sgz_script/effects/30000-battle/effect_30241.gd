extends "effect_30000.gd"

#骉枪锁定技
#【骉枪】小战场，锁定技。你默认7步3骑。你方步兵攻击方式改为掷标枪攻击:攻击距离1~3。伤害倍率1

func on_trigger_30003()->bool:
	bf.update_extra_formation_setting(
		actorId, ske.skill_name, "常规", {
			"兵种数量": {"步":7,"骑":3},
			"分配顺序": ["步", "骑"],
		}
	)
	return false

func on_trigger_30024()->bool:
	var unitId = get_env_int("白兵.初始化单位ID")
	var bu = get_battle_unit(unitId)
	if bu == null or bu.disabled:
		return false
	if bu.Type == "步":
		bu.reset_combat_info("步(标枪)")
		bu.set_combat_val("投掷类型", 2, ske.skill_name)
	return false
