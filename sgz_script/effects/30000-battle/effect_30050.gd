extends "effect_30000.gd"

#重击技能实现
#【重击】小战场,锁定技。你的主将每第二次伤害1.5倍。

func check_trigger_correct():
	if not DataManager.common_variable.has("白兵伤害.单位") \
		or not DataManager.common_variable.has("白兵伤害.伤害") \
		or not DataManager.common_variable.has("白兵伤害.来源"):
		return false

	var unitId:int = int(DataManager.common_variable["白兵伤害.来源"])
	var bu:Battle_Unit = DataManager.battle_units[unitId]
	if bu.leaderId != self.actorId:
		return false
	if bu.get_unit_type() != "将":
		return false
	if bu.wait_action_times != 0: # 仅最后一击有效
		return false

	var damage:float = float(DataManager.common_variable["白兵伤害.伤害"])
	damage = damage * 1.5
	set_env("白兵伤害.伤害", damage)

	return false
