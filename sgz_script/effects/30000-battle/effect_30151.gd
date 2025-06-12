extends "effect_30000.gd"

#缮甲效果实现
#【缮甲】小战场，锁定技。白刃战开始时，你的“统”临时增加装备防御力值。

func on_trigger_30006():
	var sbp = ske.get_battle_skill_property()
	sbp.leader += int(actor.get_equip_attr_total("防御力"))
	ske.apply_battle_skill_property(sbp)
	ske.battle_report()
	return false
