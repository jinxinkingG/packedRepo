extends "effect_30000.gd"

#夺马技能实现
#【夺马】小战场，锁定技。你方士兵击杀敌方骑兵时，你方某一步兵的兵力+50，并变为骑兵。

func on_trigger_30023() -> bool:
	var bu = ske.battle_is_unit_hit_by(UNIT_TYPE_SOLDIERS, ["骑"], ["ALL"])
	if bu == null:
		return false

	var hurtId = DataManager.get_env_int("白兵.受伤单位")
	var hurtUnit = ske.get_battle_unit(hurtId)
	if hurtUnit == null or not hurtUnit.disabled:
		return false

	if not hurtUnit.disabled:
		# 未被击杀
		return false

	var affectedUnit = null
	if bu.get_unit_type() == "步":
		affectedUnit = bu
	else:
		var minDistance = INF
		for b in bf.battle_units(actorId):
			if b.get_unit_type() != "步":
				continue
			var distance = Global.get_distance(b.unit_position, bu.unit_position)
			if distance < minDistance:
				minDistance = distance
				affectedUnit = b
	if affectedUnit == null:
		return false
	affectedUnit.set_hp(affectedUnit.get_hp() + 50)
	affectedUnit.reset_type("骑")
	affectedUnit.add_status_effect("夺马")
	return false
