extends "effect_30000.gd"

#连劲小战场效果 
#【连劲】小战场，锁定技。每个回合你的同一兵种对同一敌方单位造成的伤害递增10%。生效一次后，失去本技能。

func on_trigger_30003()->bool:
	# 借用获得【接力】来实现效果
	ske.battle_add_skill(actorId, "接力", 99999)
	ske.battle_report()
	ske.recorded = 0
	ske.remove_war_skill(actorId, ske.skill_name)
	ske.war_report()
	return false
