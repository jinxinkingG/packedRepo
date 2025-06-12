extends "effect_30000.gd"

#轻甲小战场效果 
#【轻甲】小战场，锁定技。白刃战初始，你的护甲值+10。生效一次后本技能消失。

func on_trigger_30005()->bool:
	var unit = me.battle_actor_unit()
	if unit == null:
		return false
	ske.battle_cd(99999)
	ske.battle_change_unit_armor(unit, 10)
	ske.battle_report()
	ske.recorded = 0
	ske.remove_war_skill(actorId, ske.skill_name)
	ske.war_report()
	return false
