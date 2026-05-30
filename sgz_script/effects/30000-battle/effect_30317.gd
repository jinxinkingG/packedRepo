extends "effect_30000.gd"

# 投车效果实现
#【投车】小战场，锁定技。弓兵变投石车。投石车：每回合1动，攻击距离2~5，伤害倍率=0.2+距离*0.2，免伤倍率0，

func on_trigger_30024()->bool:
	var unitId = DataManager.get_env_int("白兵.初始化单位ID")
	var bu = bf.battle_unit(unitId)
	if bu == null or bu.disabled:
		return false
	if bu.Type == "弓":
		bu.reset_type("弓(投石车)")
		bu.set_combat_val("投掷类型", 3, ske.skill_name)
		bu.set_combat_val("锁定士气", 99, ske.skill_name)
	return false
