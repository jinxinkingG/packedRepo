extends "effect_30000.gd"

#引火小战场效果 
#【引火】小战场，锁定技。每个弓兵攻击时，前三箭自动附带火矢效果。生效一次后失去此技能。

const ENHANCEMENT = {
	"火矢": 3,
	"BUFF": 1,
}

func on_trigger_30099()->bool:
	ske.remove_war_skill(actorId, ske.skill_name)
	ske.war_report()
	return false

func on_trigger_30024()->bool:
	var bu = ske.battle_enhance_current_unit(ENHANCEMENT, ["弓"])
	if bu == null:
		return false
	# 不重复汇报
	if ske.battle_get_skill_val_int() > 0:
		return false
	ske.battle_set_skill_val(1)
	ske.append_message("弓兵获得火矢增强")
	ske.battle_report()
	return false
