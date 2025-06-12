extends "effect_30000.gd"

#冲阵锁定技
#【冲阵】小战场，锁定技。你每次攻击，将对攻击范围内的所有敌兵，依次攻击1次，每次伤害递减20%，伤害下限为20%。且场上其他武将拥有<枪神>时，伤害递减改为10%

const EFFECT_ID = 30002
const QITU_EFFECT_ID = 30208

# 技能是否有效，为【冲魄】等扩展技能保留
func skill_available()->bool:
	# 与【骑突】互斥
	if ske.get_battle_skill_val_int(QITU_EFFECT_ID) > 0:
		return false
	return true

# 攻击特效标签
func get_attack_tag(marked:Array, attacked:int)->String:
	if marked.size() == 1 or attacked >= 2:
		return "冲阵"
	return ["七探", "盘蛇"][attacked % 2]

func get_loss_rate()->float:
	# 简单处理，直接使用枪神触发标记，不再扫描技能，提速
	if DataManager.get_env_int("战争.童渊弟子") > 0:
		return 0.1
	return 0.2

# 单位行动决策后
func on_trigger_30001() -> bool:
	if not skill_available():
		return false
	var unit = get_action_unit()
	if unit == null or unit.disabled:
		return false
	if unit.get_unit_type() != "将":
		# 必须是武将
		return false
	if not "攻击" in unit.has_action_task():
		# 非攻击行为时，不考虑
		return false
	# 更新攻击范围内的目标信息
	var marked = update_target_units(unit)
	if marked.empty():
		return false
	# 获取武将身侧敌军信息
	var target = get_next_atk_unit()
	if target.empty():
		return false
	# 有目标，标记更新目标记录
	var targetId = int(target["unitId"])
	var targetUnit = get_battle_unit(targetId)
	if targetUnit == null:
		return false
	# 计算标签和倍率
	var attacked = 0
	for m in marked:
		if int(m["has_action"]) > 0:
			attacked += 1
	unit.append_once_attack_tag(get_attack_tag(marked, attacked), 5)
	var rate = 1.0
	unit.append_once_damage_rate(max(0.2, 1.0 - attacked * get_loss_rate()))
	# 追加攻击目标
	mark_target_attacked(targetId)
	var targets = [targetId]
	targets.append_array(unit.get_unit_equip_effect_area(targetUnit, target["dir"]))
	unit.remove_action_task()
	var action = {
		"单位ID": unit.unitId,
		"行为方式": "攻击",
		"目标坐标": "{0},{1}".format([
			targetUnit.unit_position.x,
			targetUnit.unit_position.y
		])
	}
	if not get_next_atk_unit().empty():
		unit.other_wait_type = "攻击"
		unit.wait_action_times += 1
	DataManager.battle_first_sort.append(action)
	DataManager.common_variable["白兵.攻击目标"] = targets
	unit.action_run_call_UI()
	return false

# 单位行动完成
func on_trigger_30002()->bool:
	if not skill_available():
		return false
	var unit = get_action_unit()
	if unit == null or unit.get_unit_type() != "将":
		# 必须是武将
		return false
	# 获取武将身侧敌军信息
	var target = get_next_atk_unit()
	if target.empty():
		unit.other_wait_type = ""
		# 轮次完成，清除标记
		ske.set_battle_skill_val(null, 0, EFFECT_ID)
	return false

func mark_target_attacked(targetId:int)->void:
	# 这里固定使用冲阵 effect id，与冲魄等下位技能配合
	var marked = ske.get_battle_skill_val(EFFECT_ID)
	if typeof(marked) != TYPE_ARRAY:
		return
	var found = false
	for enemy in marked:
		if int(enemy["unitId"]) == targetId:
			enemy["has_action"] = 1
			found = true
			break
	if not found:
		return
	ske.set_battle_skill_val(marked, 1, EFFECT_ID)
	return

func update_target_units(unit:Battle_Unit)->Array:
	var marked = ske.get_battle_skill_val_array(EFFECT_ID)
	var enemiesInArea = unit.get_unit_attack_area()
	for dir in enemiesInArea:
		var enemies = enemiesInArea[dir]
		for enemy in enemies:
			if enemy.get_unit_type() == "将":
				continue
			var existed = false
			for existing in marked:
				if int(existing["unitId"]) == enemy.unitId:
					existed = true
					break
			if existed:
				continue
			var dic = {
				"unitId": enemy.unitId,
				"has_action": 0,
				"dir": dir
			}
			marked.append(dic)
	ske.set_battle_skill_val(marked, 1, EFFECT_ID)
	return marked

func get_next_atk_unit()->Dictionary:
	var unit = get_action_unit()
	#获取武将的攻击范围
	var enemiesAround = ske.get_battle_skill_val(EFFECT_ID)
	if typeof(enemiesAround) != TYPE_ARRAY:
		return {}
	for enemy in enemiesAround:
		var dir = enemy["dir"]
		var tar_unitId = int(enemy["unitId"])
		var has_action = int(enemy["has_action"])
		if has_action > 0:
			continue
		return enemy
	return {}
