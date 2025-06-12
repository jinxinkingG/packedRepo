extends "effect_30000.gd"

#振勇锁定技 #士兵强化
#【振勇】小战场，锁定技。你方士兵基础攻击倍率+0.06，基础减伤倍率+0.06。生效一次后，失去本技能。

const ENHANCEMENT = {
	"额外伤害": 0.06,
	"额外免伤": 0.06,
	"BUFF": 1,
}

func on_trigger_30024()->bool:
	ske.battle_enhance_current_unit(ENHANCEMENT, UNIT_TYPE_SOLDIERS)
	return false

func on_trigger_30099()->bool:
	ske.remove_war_skill(actorId, ske.skill_name)
	return false
