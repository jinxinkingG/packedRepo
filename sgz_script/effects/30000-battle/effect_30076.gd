extends "effect_30000.gd"

#毒矢效果
#【毒矢】小战场,锁定技。被你方弓兵射中的士兵单位，下回合初始，其兵力-10。

func on_trigger_30009()->bool:
	# 受击单位数组
	for unitId in ske.get_battle_skill_val_int_array():
		var bu = get_battle_unit(unitId)
		if bu == null or bu.disabled or bu.leaderId == me.actorId:
			continue
		ske.battle_change_unit_hp(bu, -10)
		bu.wait_action_name = "减体|-10"

	# 清空标记
	ske.set_battle_skill_val([])
	ske.battle_report()
	return false

func on_trigger_30023()->bool:
	var bu = ske.battle_is_unit_hit_by(["弓"], UNIT_TYPE_SOLDIERS, ["射箭"])
	if bu == null:
		return false
	var hurtId = get_env_int("白兵伤害.单位")
	var hurt = get_battle_unit(hurtId)
	if hurt == null or hurt.disabled:
		return false
	var hit = []
	hit.append_array(ske.get_battle_skill_val_int_array())
	hit.erase(hurt.unitId)
	hit.append(hurt.unitId)
	ske.set_battle_skill_val(hit)
	return false
