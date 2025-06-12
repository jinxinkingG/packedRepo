extends "effect_30000.gd"

#广射锁定效果
#【广射】小战场，主动技。消耗 5 战术值发动，此后的三回合，回合结束时，你弯弓射日，对全场随机1名敌方单位造成射箭伤害。小战场限1次。

const ACTIVE_EFFECT_ID = 30269

func on_trigger_30059() -> bool:
	var flag = ske.battle_get_skill_val_int(ACTIVE_EFFECT_ID)
	if flag <= 0:
		return false

	var unit = me.battle_actor_unit()
	if unit == null:
		return false

	var bf = DataManager.get_current_battle_fight()
	var targets = []
	for bu in bf.battle_units(enemy.actorId):
		if bu.get_unit_type() in ["城门"]:
			continue
		if not unit.shootable(bu):
			continue
		targets.append(bu)
	if targets.empty():
		return false
	
	var bia = Battle_Instant_Action.new()
	bia.unitId = unit.unitId
	bia.action = "广射"
	bia.targetUnitId = 0
	bia.targetPos = Vector2.ZERO
	bia.actionTimes = 1
	bia.insert_to_env()
	return false
