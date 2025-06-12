extends "effect_30000.gd"

#挺刺技能实现
#【挺刺】小战场，锁定技。你触发穿刺时，士气+1。

func on_trigger_30023():
	var bu = ske.battle_is_unit_hit_by(["将"], UNIT_TYPE_SOLDIERS, ["攻击"])
	if bu == null:
		return false
	var speared = get_env_int_array("白兵.枪类影响目标")
	var hurtId = get_env_int("白兵伤害.单位")
	if not hurtId in speared:
		return false

	ske.battle_change_morale(1, me)
	ske.battle_report()

	bu.add_status_effect("士气 +1")
	return false
