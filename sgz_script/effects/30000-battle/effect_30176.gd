extends "effect_30000.gd"

#游弓及游弩效果
#【游弓】小战场，锁定技。你的强弩或者火矢持续回合内，你的弓兵击中对面单位后，立即自动后退状态移动一次。
#【游弩】小战场，锁定技。你方弓兵因<游弓>效果，射中敌方目标并后退1步的场合：若目标单位未死亡，立即对之进行1次追加射击，这次追击的伤害为原本的50%，但无距离限制。

func on_trigger_30023()->bool:
	var turns = me.get_buff("强弩")["回合数"] + me.get_buff("火矢")["回合数"]
	if turns <= 0:
		return false

	var attackUnit = ske.battle_is_unit_hit_by(["弓"], ["ALL"], ["ALL"])
	if attackUnit == null:
		return false
	if attackUnit.dic_combat.has("ONCE.临时行动"):
		return false
	if attackUnit.leaderId != actorId:
		return false
	if attackUnit.get_unit_type() != "弓":
		return false
	if attackUnit.last_action_name != "射箭":
		return false

	var targetUnitId = DataManager.get_env_int("白兵伤害.单位")
	var targetUnit = get_battle_unit(targetUnitId)
	if targetUnit == null or targetUnit.disabled:
		return false

	# 如果已经在本方最后一行，不动
	match attackUnit.get_side():
		Vector2.LEFT:
			if attackUnit.unit_position.x <= 0:
				return false
		Vector2.RIGHT:
			if attackUnit.unit_position.x >= SceneManager.current_scene().cell_columns - 1:
				return false
	if SkillHelper.actor_has_skills(actorId, ["游弩"]):
		var bia = Battle_Instant_Action.new()
		bia.unitId = attackUnit.unitId
		bia.action = "射箭@游弩@0.5"
		bia.targetUnitId = targetUnit.unitId
		bia.targetPos = targetUnit.unit_position
		bia.actionTimes = 1
		bia.insert_to_env()
	# 插入临时行动，尝试后退，以游走方式实现
	var bia = Battle_Instant_Action.new()
	bia.unitId = attackUnit.unitId
	bia.action = "游走"
	bia.targetUnitId = -1
	bia.targetPos = attackUnit.unit_position + attackUnit.get_side()
	bia.actionTimes = 1
	bia.insert_to_env()
	return false
