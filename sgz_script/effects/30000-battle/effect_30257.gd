extends "effect_30000.gd"

#绝勇锁定技 #武将强化
#【绝勇】小战场,锁定技。你触发 {侧斩} 或者 {穿刺} 时，护甲+1；你的护甲值＞0时，护甲可承受超出该护甲值的伤害。

func on_trigger_30023()->bool:
	var bu = get_leader_unit(me.actorId)
	if bu == null:
		return false

	var attackUnitId = DataManager.get_env_int("白兵伤害.来源")
	if attackUnitId != bu.unitId:
		return false

	var defendUnitId = DataManager.get_env_int("白兵伤害.单位")
	var hurtId = DataManager.get_env_int("白兵.受伤单位")
	if defendUnitId != hurtId:
		return false
	var speared = DataManager.get_env_int_array("白兵.枪类影响目标")
	# 剑类判断比较特殊，数组内id已经被pop，有数组就是侧击
	if speared.empty() and not DataManager.check_env(["白兵.剑类影响目标"]):
		return false
	if hurtId in speared:
		# 只计主单位
		return false

	ske.battle_change_unit_armor(bu, 1)
	return false
