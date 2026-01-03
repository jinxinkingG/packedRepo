extends "effect_30000.gd"

#强袭效果实现
#【强袭】小战场,锁定技。你被敌方士兵近身攻击时，立即对其进行1次反击，反击效果等同于近身攻击。

func on_trigger_30011() -> bool:
	var bu = ske.battle_is_unit_hit_by(UNIT_TYPE_SOLDIERS, ["将"], ["ALL"], true)
	if bu == null:
		return false

	var hurtId = DataManager.get_env_int("白兵伤害.单位")
	var hurt = bf.battle_unit(hurtId)
	if hurt == null:
		return false

	if Global.get_distance(hurt.unit_position, bu.unit_position) != 1:
		return false

	var bia: Battle_Instant_Action = Battle_Instant_Action.new()
	bia.unitId = hurt.unitId
	bia.action = "攻击@强袭#FF0000"
	bia.targetUnitId = bu.unitId
	bia.targetPos = bu.unit_position
	bia.insert_to_env()

	return false

