extends "effect_30000.gd"

#无前锁定技 #武将强化
#【无前】单挑，锁定技。你免疫暴击，且造成伤害时，回复伤害量X%的血量（X＝你的等级*5）。

const ENHANCEMENT = {
	"临界护甲": 1,
	"BUFF": 1
}

func on_trigger_30024()->bool:
	ske.battle_enhance_current_unit(ENHANCEMENT, ["将"])
	return false

func on_trigger_30023()->bool:
	var bu = get_leader_unit(me.actorId)
	if bu == null:
		return false

	var attackUnitId = DataManager.get_env_int("白兵伤害.来源")
	if attackUnitId != bu.unitId:
		return false

	var defendUnitId = DataManager.get_env_int("白兵伤害.单位")
	var hurtId = DataManager.get_env_int("白兵.受伤单位")
	if defendUnitId != hurtId:
		return false
	var speared = DataManager.get_env_int_array("白兵.枪类影响目标")
	var splashed = DataManager.get_env_int_array("白兵.刀类影响目标")
	# 刀类特殊，主要目标也在列表中
	if speared.empty() and splashed.size() <= 1:
		return false
	# 只计主单位
	if hurtId in speared:
		return false
	if splashed.size() > 0 and hurtId != splashed[0]:
		return false

	ske.battle_change_unit_armor(bu, 1)
	return false
