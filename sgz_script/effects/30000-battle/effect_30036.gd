extends "effect_30000.gd"

#血战技能实现
#【血战】小战场,锁定技。对方每减少1个士兵单位，你的战术值+2。

func on_trigger_30005()->bool:
	var enemyUnitsCount = get_enemy_unit_count()
	if enemyUnitsCount <= 0:
		ske.battle_cd(99999)
		return false
	ske.battle_set_skill_val(enemyUnitsCount)
	return false

func on_trigger_30007()->bool:
	var prev = ske.battle_get_skill_val_int()
	var current = get_enemy_unit_count()
	# 更新单位数，以便后续判断
	ske.battle_set_skill_val(current)
	if current >= prev:
		return false

	ske.battle_change_tactic_point((prev - current) * 2)
	return false

# 获取敌方有效士兵单位数量
func get_enemy_unit_count()->int:
	var ret = 0
	for bu in DataManager.battle_units:
		if bu.leaderId == actorId:
			continue
		if bu.get_unit_type() == "将":
			continue
		if bu.disabled:
			continue
		ret += 1
	return ret
