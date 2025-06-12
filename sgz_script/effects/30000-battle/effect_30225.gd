extends "effect_30000.gd"

#鼓锐被动效果
#【鼓锐】小战场，主动技。你可以消耗至多15点战术值发动。本轮次中，你方所有单位对敌兵造成的伤害值+X点（X=发动该效果消耗的战术值）。每个大战场回合限1次。

func on_trigger_30021()->bool:
	var x = ske.battle_get_skill_val_int()
	if x <= 0:
		return false
	var bu = ske.battle_extra_damage(x, ["ALL"], ["ALL"], UNIT_TYPE_SOLDIERS)
	if bu == null:
		return false
	var msg = "{0} +{1}#FF0000".format([ske.skill_name, x])
	bu.add_status_effect(msg)
	return false
