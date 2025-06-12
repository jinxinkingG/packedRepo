extends "effect_30000.gd"

#重锤效果实现
#【重锤】小战场，锁定技。你持锤类武器时，你行动结束后，对某个斜角单位追加一次伤害100%的攻击。

func on_trigger_30002():
	var unit = get_action_unit()
	if unit == null:
		return false
	if unit.leaderId != actorId or unit.get_unit_type() != "将":
		return false
	if unit.wait_action_times > 0:
		return false
	if not "锤" in unit.get_unit_equip():
		return false
	if ske.get_battle_skill_val_int() == unit.unitId + 1:
		# 发动过了
		return false
	# 遍历敌方单位，如果在斜向身周，则插入临时行动触发重锤
	var targets = []
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled:
			continue
		if bu.leaderId == actorId or bu.get_unit_type() == "将":
			continue
		var disv = unit.unit_position - bu.unit_position
		if abs(disv.x) == 1 and abs(disv.y) == 1:
			targets.append(bu)
	if targets.empty():
		return false
	targets.shuffle()
	var target = targets[0]
	ske.set_battle_skill_val(unit.unitId + 1, 1)
	unit.append_once_damage_rate(1)
	var bia = Battle_Instant_Action.new()
	bia.unitId = unit.unitId
	bia.action = "攻击@重锤"
	bia.targetUnitId = target.unitId
	bia.targetPos = target.unit_position
	bia.actionTimes = 1
	bia.targets = [target.unitId]
	bia.insert_to_env()
	return false
