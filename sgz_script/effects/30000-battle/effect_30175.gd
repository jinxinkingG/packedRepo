extends "effect_30000.gd"

#飞羽小战场效果 
#【飞羽】小战场，锁定技。白刃战时，你的兵种变为全弓，生效一次后失去此技能。

const EFFECT_ID = 30175

func on_trigger_30003()->bool:
	var formationKey = "白兵.阵型优先.{0}".format([actorId])
	if DataManager.get_env_int(formationKey) >= 1:
		return false

	DataManager.set_env("兵种数量", {"弓":10})
	DataManager.set_env("分配顺序", ["弓"])
	DataManager.set_env(formationKey, 1)
	ske.append_message("全弓列阵")
	ske.battle_report()
	ske.recorded = 0
	ske.ban_war_skill(actorId, ske.skill_name, 1)
	# 汇报到大战场
	ske.war_report()
	return false
