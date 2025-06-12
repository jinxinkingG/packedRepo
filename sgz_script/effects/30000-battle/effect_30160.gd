extends "effect_30000.gd"

#狂斧效果实现
#【狂斧】小战场，锁定技。若你的武器名称中包含“斧”字，你行动结束后，对你周围1圈内的所有敌兵造成30%的伤害。

func on_trigger_30002():
	var unit = get_action_unit()
	if unit == null:
		return false
	if unit.leaderId != self.actorId or unit.get_unit_type() != "将":
		return false
	if unit.wait_action_times > 0:
		return false
	if not "斧" in unit.get_unit_equip():
		return false
	if ske.get_battle_skill_val_int() == unit.unitId + 1:
		# 发动过了
		return false
	# 遍历敌方单位，如果在身周，则插入临时行动触发狂斧
	var targets = []
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled:
			continue
		if bu.leaderId == self.actorId or bu.get_unit_type() == "将":
			continue
		var disv = unit.unit_position - bu.unit_position
		if max(abs(disv.x), abs(disv.y)) == 1:
			targets.append(bu.unitId)
	if targets.empty():
		return false
	ske.set_battle_skill_val(unit.unitId + 1, 1)
	unit.append_once_damage_rate(0.3)
	var bia = Battle_Instant_Action.new()
	bia.unitId = unit.unitId
	bia.action = "攻击@狂斧"
	bia.targetUnitId = -1
	bia.targetPos = unit.unit_position
	bia.actionTimes = 1
	bia.targets = targets
	bia.insert_to_env()
	return false
