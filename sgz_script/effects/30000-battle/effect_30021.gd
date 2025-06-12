extends "effect_30000.gd"

#漫射效果实现
#【漫射】小战场，锁定技。你射箭命中对手时，自动对“射程+1”范围内至多3个随机敌方士兵追加一次50%伤害的射箭攻击。

func on_trigger_30023():
	var bu = get_action_unit()
	if bu == null or bu.disabled:
		return false
	if bu.leaderId != me.actorId or bu.get_unit_type() != "将":
		return false
	if bu.last_action_name != "射箭":
		return false
	if "漫射" in bu.get_once_attack_tags_all():
		# 别没完没了
		return false
	var targetId = get_env_int("白兵伤害.单位")
	var target = get_battle_unit(targetId)
	if target == null:
		return false
	var bia = Battle_Instant_Action.new()
	bia.unitId = bu.unitId
	bia.action = "漫射"
	bia.targetUnitId = target.unitId
	bia.targetPos = target.unit_position
	bia.actionTimes = 1
	bia.insert_to_env()
	return false
