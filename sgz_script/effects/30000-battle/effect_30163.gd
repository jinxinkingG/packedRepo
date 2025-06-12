extends "effect_30000.gd"

#夺马技能实现
#【夺马】小战场，锁定技。你方步兵击杀敌方骑兵时，该步兵的兵力+50，并变为骑兵。

func check_trigger_correct():
	if not check_env(["白兵伤害.单位", "白兵伤害.伤害", "白兵伤害.来源"]):
		return false

	var attackUnitId = int(get_env("白兵伤害.来源"))
	var attackUnit = DataManager.battle_units[attackUnitId]
	if attackUnit.leaderId != self.actorId:
		return false
	if attackUnit.get_unit_type() == "将":
		return false

	var defendUnitId = int(get_env("白兵伤害.单位"))
	var defendUnit = DataManager.battle_units[defendUnitId]
	if defendUnit.leaderId == self.actorId:
		return false
	if defendUnit.get_unit_type() != "骑":
		return false
	if not defendUnit.disabled:
		# 未被击杀
		return false

	var affectedUnit = null
	if attackUnit.get_unit_type() == "步":
		affectedUnit = attackUnit
	else:
		for bu in DataManager.battle_units:
			if bu == null or bu.disabled:
				continue
			if bu.leaderId != self.actorId:
				continue
			if bu.get_unit_type() != "步":
				continue
			affectedUnit = bu
			break
	if affectedUnit == null:
		return false
	affectedUnit.set_hp(affectedUnit.get_hp() + 50)
	affectedUnit.init_combat_info("骑")
	affectedUnit.add_status_effect("夺马")
	return false
