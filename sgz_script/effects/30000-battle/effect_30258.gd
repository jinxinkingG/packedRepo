extends "effect_30000.gd"

#马步技能实现
#【马步】小战场，锁定技。你的骑兵单位兵力变0时，恢复50兵力，变为步兵。每个士兵单位限1次。

func on_trigger_30023() -> bool:
	var bu = ske.battle_is_unit_hit_by(["ALL"], ["骑"], ["ALL"])
	if bu == null:
		return false

	var hurtId = DataManager.get_env_int("白兵.受伤单位")
	var hurtUnit = ske.get_battle_unit(hurtId)
	if hurtUnit == null or not hurtUnit.disabled:
		return false

	# 只对自己发动
	if hurtUnit.leaderId != actorId:
		return false

	if not hurtUnit.reset_type("步"):
		return false

	hurtUnit.set_hp(50, true)
	hurtUnit.disabled = false
	hurtUnit.add_status_effect("马步")
	return false
