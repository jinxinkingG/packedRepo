extends "effect_30000.gd"

# 冲骑技能实现
#【冲骑】小战场，锁定技。白刃战的同一轮次中，你移动后的下次攻击附带击退效果。

func on_trigger_30002() -> bool:
	var bu = me.battle_actor_unit()
	if bu == null or bu.disabled:
		return false
	ske.set_battle_skill_val(0, 1)
	if bu.last_action_name == "移动":
		# 打开开关
		ske.set_battle_skill_val(1, 1)
	return false

func on_trigger_30021() -> bool:
	# 要求上一次动作为移动
	var flag = ske.get_battle_skill_val_int()
	if flag <= 0:
		return false

	var bu = ske.battle_is_unit_hit_by(["将"], ["SOLDIERS"], ["攻击"])
	if bu == null:
		return false

	var targetUnitId = DataManager.get_env_int("白兵伤害.单位")
	var targetUnit = get_battle_unit(targetUnitId)
	if targetUnit == null or targetUnit.disabled:
		return false
	# 与巨力不同，冲骑不要求目标近身

	var beatPos = targetUnit.unit_position - targetUnit.unit_position.direction_to(bu.unit_position)
	if targetUnit.can_move_to_position(beatPos):
		bu.add_status_effect("冲骑")
		targetUnit.add_status_effect("击退")
		targetUnit.wait_action_name = "击退|{0},{1}".format([beatPos.x, beatPos.y])
	return false
