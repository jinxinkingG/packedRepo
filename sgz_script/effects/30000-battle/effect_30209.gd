extends "effect_30002.gd"

#骑突锁定效果
#【骑突】小战场，主动技。消耗5点战术值发动。你可回到本次白刃战中你移动过的任意一个空格，那之后你对目标点周围的敌兵追加一次的<冲阵>攻击。白刃战限1次。

func skill_available()->bool:
	if ske.get_battle_skill_val_int(QITU_EFFECT_ID) != 1:
		return false
	var target = get_next_atk_unit()
	if target.empty():
		ske.set_battle_skill_val(0, 0, QITU_EFFECT_ID)
		return false
	return true

func get_attack_tag(marked:Array, attacked:int)->String:
	return "骑突"

# 重写冲阵的回调，配合骑突的临时冲阵机制
func on_trigger_30002()->bool:
	if not skill_available():
		return false
	var unit = get_action_unit()
	if unit == null or unit.get_unit_type() != "将":
		# 必须是武将
		return false
	# 获取武将身侧敌军信息
	var targetDic = get_next_atk_unit()
	if targetDic.empty():
		unit.other_wait_type = ""
		# 轮次完成，清除标记
		ske.set_battle_skill_val(null, 0, EFFECT_ID)
		ske.set_battle_skill_val(0, 0, QITU_EFFECT_ID)
		return false
	# 仍有可攻击单位，继续
	var targetId = int(targetDic["unitId"])
	var targetUnit = get_battle_unit(targetId)
	unit.append_once_attack_tag("骑突", 9)
	var bia = Battle_Instant_Action.new()
	bia.unitId = unit.unitId
	bia.action = "攻击@骑突"
	bia.targetUnitId = targetId
	bia.targetPos = targetUnit.unit_position
	bia.actionTimes = 1
	bia.targets = []
	bia.insert_to_env()
	mark_target_attacked(targetId)
	return false
