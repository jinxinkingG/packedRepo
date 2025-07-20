extends "effect_30000.gd"

# 飞戟效果
#【飞戟】小战场，锁定技。你可发动飞戟投掷攻击，投掷距离 2-4，每次投掷，都消耗一个「戟」，并在目标位置留下一个「残戟」标记。战斗初始，你拥有6个「戟」 。移动到「残戟」附近位置即可回收一个「戟」。若你的武器名含「戟」，则飞戟投掷附加 10% 吸血效果，投掷飞戟击杀敌方单位时，立刻回收残戟。

const LIMIT = 6

func on_trigger_30005() -> bool:
	var bu = me.battle_actor_unit()
	if bu == null:
		return false
	update_runtime_status(bu)
	return false

func on_trigger_30002() -> bool:
	var unit = get_action_unit()
	if unit == null or unit.get_unit_type() != "将":
		# 必须是武将
		return false
	if unit.last_action_name != "移动":
		return false
	# 移动后，判断是否可收回飞戟
	var positions = ske.get_battle_skill_val_int_array()
	var updated = []
	for posVal in positions:
		var x = int(posVal / 100)
		var y = posVal % 100
		if Global.get_distance(unit.unit_position, Vector2(x, y)) <= 1:
			continue
		updated.append(posVal)
	if updated.size() != positions.size():
		unit.add_status_effect("回戟")
	ske.set_battle_skill_val(updated)
	update_runtime_status(unit)
	return false

func on_trigger_30023() -> bool:
	var bu = ske.battle_is_unit_hit_by(["将"], ["ALL"], ["投掷"])
	if bu == null:
		return false

	if bu.get_throw_type() != 1:
		# 非飞戟投掷
		return false

	var targetUnitId = DataManager.get_env_int("白兵伤害.单位")
	var targetUnit = get_battle_unit(targetUnitId)
	if targetUnit == null:
		return false

	# 飞戟吸血效果
	var damage = DataManager.get_env_int("白兵伤害.伤害")
	var weapon = actor.get_weapon()
	if not weapon.disabled and "戟" in weapon.name():
		var recover = int(damage / 10)
		if recover > 0:
			bu.add_status_effect("飞戟 +{0}".format([recover]))
			ske.battle_change_unit_hp(bu, recover)

	# 飞戟造成伤害，判断目标状态
	if not targetUnit.disabled:
		# 目标未死亡，标记残戟位置
		var posVal = targetUnit.unit_position.x * 100 + targetUnit.unit_position.y
		var positions = ske.get_battle_skill_val_int_array()
		positions.append(posVal)
		ske.set_battle_skill_val(positions)
		update_runtime_status(bu)
	return false

func update_runtime_status(bu:Battle_Unit) -> void:
	var positions = ske.get_battle_skill_val_int_array()
	var left = LIMIT - positions.size()
	left = max(0, left)
	if left == 0:
		# 残戟已经用完，标记不可投掷
		bu.set_combat_val("投掷距离", 0, ske.skill_name)
	else:
		# 恢复投掷能力
		bu.set_combat_val("投掷距离", 4, ske.skill_name)
		bu.set_combat_val("投掷类型", 1, ske.skill_name)
	bf.set_env("战斗动态信息." + str(actorId), " 戟 x" + str(left))
	return
