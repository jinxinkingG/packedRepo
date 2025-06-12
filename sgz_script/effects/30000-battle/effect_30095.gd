extends "effect_30000.gd"

#锐步效果实现
#【锐步】小战场,锁定技。对方士兵行动结束时，若其处于你方步兵单位的攻击范围内，则己方步兵对之发起攻击，造成50%的伤害。

func on_trigger_30002():
	var unitId = get_env_int("白兵.行动单位")
	var unit = get_battle_unit(unitId)
	if unit == null or unit.disabled:
		return false
	if unit.leaderId == me.actorId or unit.get_unit_type() == "将" or unit.wait_action_times > 0:
		return false
	# 避免暴走、狂斧等情况没完没了
	if unit.dic_combat.has("ONCE.临时行动"):
		return false
	# 遍历我方所有步兵，检查其攻击范围，如果当前单位落到攻击范围内，则插入临时行动触发攻击
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled:
			continue
		if bu.leaderId != me.actorId or bu.get_unit_type() != "步":
			continue
		for i in bu.get_attack_distance():
			for dir in StaticManager.NEARBY_DIRECTIONS:
				var pos = bu.unit_position + (i + 1) * dir
				if pos == unit.unit_position:
					bu.append_once_damage_rate(0.5)
					var bia = Battle_Instant_Action.new()
					bia.unitId = bu.unitId
					bia.action = "攻击@锐步"
					bia.targetUnitId = unit.unitId
					bia.targetPos = unit.unit_position
					bia.actionTimes = 1
					bia.insert_to_env()
	return false
