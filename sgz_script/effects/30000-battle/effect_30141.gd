extends "effect_30000.gd"

#长矛小战场效果 
#【长矛】小战场，临时锁定技。白刃战时，步兵和骑兵攻击距离为 1~2，生效一次后失去此技能。

const ENHANCEMENT = {
	"近战距离": 2,
	"BUFF": 1,
}

func on_trigger_30099()->bool:
	ske.remove_war_skill(actorId, ske.skill_name)
	ske.war_report()
	return false

func on_trigger_30024()->bool:
	ske.battle_enhance_current_unit(ENHANCEMENT, ["步", "骑"])
	return false
