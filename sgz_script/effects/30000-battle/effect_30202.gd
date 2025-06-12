extends "effect_30000.gd"

#伏尘小战场效果 
#【伏尘】小战场，锁定技。你方士兵单位被击杀时，你发动道术在死去的士兵身上卷起沙尘暴，只要伤害来源单位不是武将类型，会直接被卷走而离场。战斗结束时，若对方获胜，其恢复因这个效果卷走的兵力数值。

func on_trigger_30013()->bool:
	var hurtId = get_env_int("白兵.受伤单位")
	var hurt = get_battle_unit(hurtId)
	if hurt == null or not hurt.disabled:
		return false
	var bu = ske.battle_is_unit_hit_by(UNIT_TYPE_SOLDIERS, UNIT_TYPE_SOLDIERS, ["ALL"], true)
	if bu == null:
		return false
	# 伏尘 action 会让单位消失
	# 这里将其标记为临时就好
	bu.dic_other_variable[ske.skill_name] = 1
	var bia = Battle_Instant_Action.new()
	bia.unitId = bu.unitId
	bia.action = "伏尘"
	bia.targetUnitId = -1
	bia.targetPos = Vector2(-1, -1)
	bia.actionTimes = 1
	bia.insert_to_env()
	return false

func on_trigger_30099()->bool:
	var bf = DataManager.get_current_battle_fight()
	# 如果我失败了，什么都不做
	if me.actorId == bf.loserId:
		return false
	# 否则，将对方标记了「伏尘」的单位，都标记为「临时」
	# 以此达到扣减兵力的效果
	for bu in DataManager.battle_units:
		if bu == null or bu.leaderId == me.actorId:
			continue
		if not bu.dic_other_variable.has(ske.skill_name):
			continue
		bu.dic_other_variable["临时"] = 1
	return false
