extends "effect_30000.gd"

#勇箭技能实现
#【勇箭】小战场,锁定技。你与你方士兵用弓箭射杀对方士兵单位时，你方士气+1。


func on_trigger_30023():
	var bu = ske.battle_is_unit_hit_by(["ALL"], UNIT_TYPE_SOLDIERS, ["射箭"])
	if bu == null:
		return false

	var hurtId = get_env_int("白兵伤害.单位")
	var hurt = get_battle_unit(hurtId)
	if hurt == null or not hurt.disabled:
		return false

	ske.battle_change_morale(1, me)
	ske.battle_report()

	bu.add_status_effect("士气 +1")
	return false
