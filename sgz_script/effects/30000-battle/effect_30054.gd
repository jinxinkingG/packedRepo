extends "effect_30000.gd"

#巨力技能实现
#【巨力】小战场,锁定技。你攻击身边四格内的敌兵时，若该士兵在你击退的方向没有阻挡，你可击退该敌兵；否则，你本次攻击造成1.5倍最终伤害

func on_trigger_30021() -> bool:
	var bu = ske.battle_is_unit_hit_by(["将"], ["SOLDIERS"], ["攻击"])
	if bu == null:
		return false

	var targetUnitId = DataManager.get_env_int("白兵伤害.单位")
	var targetUnit = get_battle_unit(targetUnitId)
	if targetUnit == null or targetUnit.disabled:
		return false
	var offset = bu.unit_position - targetUnit.unit_position
	if abs(offset.x) + abs(offset.y) != 1:
		# 必须近身
		return false

	var beatPos = targetUnit.unit_position - offset
	if targetUnit.can_move_to_position(beatPos):
		targetUnit.wait_action_name = "击退|{0},{1}".format([beatPos.x, beatPos.y])
		targetUnit.add_status_effect("击退")
	else:
		var damage = DataManager.get_env_float("白兵伤害.伤害")
		DataManager.set_env("白兵伤害.伤害", damage * 1.5)
		targetUnit.add_status_effect("巨力|x1.5")
	return false
