extends "effect_30000.gd"

#神勇锁定技
#【神勇】小战场，锁定技。你触发 {横劈} 或者 {穿刺} 时，护甲+1；你的护甲值＞0时，护甲可承受超出该护甲值的伤害。

const ENHANCEMENT = {
	"临界护甲": 1,
	"BUFF": 1
}

func on_trigger_30024()->bool:
	ske.battle_enhance_current_unit(ENHANCEMENT, ["将"])
	return false

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

	# 只针对主要目标判断
	if bu.last_attack_units.empty() or hurtId != bu.last_attack_units[0]:
		return false

	var armor = 0
	var speared = DataManager.get_env_int_array("白兵.枪类影响目标")
	var splashed = DataManager.get_env_int_array("白兵.刀类影响目标")
	# 刀类，主要目标在列表中
	if splashed.size() > 1:
		armor += 1
	# 枪类，主目标不在列表中
	if speared.size() > 0:
		armor += 1

	ske.battle_change_unit_armor(bu, armor)
	return false
