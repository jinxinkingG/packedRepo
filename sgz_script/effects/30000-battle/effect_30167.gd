extends "effect_30000.gd"

#格返效果
#【格返】小战场，锁定技。你触发格挡时，若攻击范围内有对方士兵，则追加一次50%伤害的反击。

func check_trigger_correct()->bool:
	var me = DataManager.get_war_actor(self.actorId)
	if me == null or me.disabled:
		return false
	if not check_env(["白兵.受伤单位", "白兵.攻击来源"]):
		return false

	var attackUnitId = int(get_env("白兵.攻击来源"))
	if attackUnitId < 0 or attackUnitId >= DataManager.battle_units.size():
		return false
	var attackUnit = DataManager.battle_units[attackUnitId]
	if attackUnit.leaderId == actorId:
		return false

	var defendUnitId = int(get_env("白兵.受伤单位"))
	if defendUnitId < 0 or defendUnitId >= DataManager.battle_units.size():
		return false
	var defendUnit = DataManager.battle_units[defendUnitId]
	if defendUnit.leaderId != self.actorId:
		return false
	if defendUnit.get_unit_type() != "将":
		return false

	# 若未格挡不触发
	if not attackUnit.dic_other_variable.has("被格挡"):
		return false
	if not attackUnit.dic_other_variable["被格挡"]:
		return false

	# 如果攻击来源单位在范围中，优先攻击
	var target = null
	var attackables = []
	for targets in defendUnit.get_unit_attack_area().values():
		attackables.append_array(targets)
	if not attackables.empty():
		if attackUnit in attackables:
			target = attackUnit
		else:
			# 否则随机攻击一个
			attackables.shuffle()
			for _target in attackables:
				if _target.disabled:
					continue
				target = _target
				break
	if target == null:
		return false

	var bia = Battle_Instant_Action.new()
	bia.unitId = defendUnitId
	bia.action = "攻击@反击@0.5"
	bia.targetUnitId = target.unitId
	bia.targetPos = target.unit_position
	bia.actionTimes = 1
	bia.insert_to_env()
	return false
