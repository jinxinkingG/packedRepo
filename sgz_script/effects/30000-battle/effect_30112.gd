extends "effect_30000.gd"

#坚韧锁定技
#【坚韧】小战场,锁定技。对方小兵单次攻击对你造成的伤害上限从12降为9

# TODO，考虑是否用真伤视效代替

func check_trigger_correct():

	if not DataManager.common_variable.has("白兵伤害.单位") \
		or not DataManager.common_variable.has("白兵伤害.伤害") \
		or not DataManager.common_variable.has("白兵伤害.来源"):
		return false

	var unitId:int = int(DataManager.common_variable["白兵伤害.单位"])
	var bu:Battle_Unit = DataManager.battle_units[unitId]
	if bu.leaderId != self.actorId:
		return false
	if bu.get_unit_type() != "将":
		return false
	var damage = float(DataManager.common_variable["白兵伤害.伤害"])
	DataManager.common_variable["白兵伤害.伤害"] = min(9.0, damage)

	return false
