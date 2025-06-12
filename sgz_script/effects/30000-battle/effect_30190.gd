extends "effect_30000.gd"

#漫射测试效果
#【漫射测试】小战场，锁定技。每移动1步，自动对射程内的所有敌方士兵单位射箭，每个目标受到X%的伤害。X最小为10，最大为50/目标数。

func on_trigger_30002():
	var bu = get_action_unit()
	if bu == null or bu.disabled:
		return false
	if bu.leaderId != me.actorId or bu.get_unit_type() != "将":
		return false
	if bu.last_action_name != "移动":
		return false
	var bia = Battle_Instant_Action.new()
	bia.unitId = bu.unitId
	bia.action = "漫射"
	bia.targetUnitId = bu.unitId
	bia.targetPos = bu.unit_position
	bia.actionTimes = 1
	bia.insert_to_env()
	return false
