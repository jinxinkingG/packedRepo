extends "effect_30000.gd"

#龙战技能实现
#【龙战】小战场,锁定技。你对攻击对方小兵的伤害结果，额外附加你的装备攻击力。

func on_trigger_30021()->bool:
	var extraDamage = int(actor.get_equip_attr_total("攻击力"))
	var bu = ske.battle_extra_damage(extraDamage, ["将"], ["攻击"])
	if bu == null:
		return false
	var msg = "{0} +{1}#FF0000".format([ske.skill_name, extraDamage])
	bu.add_status_effect(msg)
	return false
