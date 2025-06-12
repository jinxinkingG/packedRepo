extends "effect_30000.gd"

#强袭效果实现
#【强袭】小战场,锁定技。你被敌方士兵攻击时，你将立即无视距离对其进行1次反击（攻击倍率等同于近身战斗）。

func check_trigger_correct():
	self.trace = true
	if not check_env(["白兵伤害.单位", "白兵伤害.伤害", "白兵伤害.来源"]):
		return false

	var def_id = get_env_int("白兵伤害.单位")
	var def_unit = DataManager.battle_units[def_id]
	if def_unit.get_unit_type() != "将":
		return false
	if def_unit.leaderId != self.actorId:
		return false

	var att_id = get_env_int("白兵伤害.来源")
	var att_unit = DataManager.battle_units[att_id]
	if att_unit.leaderId == self.actorId:
		return false

	var disv = att_unit.unit_position - def_unit.unit_position
	if abs(disv.x) + abs(disv.y) != 1:
		# 非近身，不允许反击
		return false

	self.trace("== 强袭 {0}：#{1} 受到 #{2} 的 {3}".format([
		self.actorId, def_id, att_id, att_unit.last_action_name
	]))

	var bia: Battle_Instant_Action = Battle_Instant_Action.new()
	bia.unitId = def_id
	bia.action = "反击"
	bia.targetUnitId = att_id
	bia.targetPos = att_unit.unit_position
	bia.insert_to_env()
	self.trace("   强袭 {0}：#{1} 准备{2} 位于<{3},{4}> 的 #{5}".format([
		self.actorId, bia.unitId, bia.action,
		bia.targetPos.x, bia.targetPos.y, bia.targetUnitId,
	]))

	return false

