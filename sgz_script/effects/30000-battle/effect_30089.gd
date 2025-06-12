extends "effect_30000.gd"

#剑舞效果
#【剑舞】小战场,锁定技。若你持「剑」，武器攻击力+10；否则，你的武器可触发「剑」的攻击特性。

func on_trigger_30024()->bool:
	var unitId = get_env_int("白兵.初始化单位ID")
	var bu = get_battle_unit(unitId)
	if bu == null or bu.disabled:
		return false
	if bu.get_unit_type() != "将":
		return false
	if bu.dic_combat.has(ske.skill_name):
		return false
	bu.dic_combat[ske.skill_name] = 1
	var weaponFeatures = bu.get_unit_equip()
	if not "剑" in weaponFeatures:
		weaponFeatures.append("剑")
		bu.dic_combat["武器特性"] = weaponFeatures
	else:
		bu.set_combat_val("额外攻击力", 10, ske.skill_name)
	return false
