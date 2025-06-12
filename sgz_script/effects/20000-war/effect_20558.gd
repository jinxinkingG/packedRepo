extends "effect_20000.gd"

#击免被动效果
#【击免】大战场，主动技。消耗10机动力，发动后，直到次回合前，你无法被选为攻击目标。每3日限1次。

const ACTIVE_EFFECT_ID = 20557

func on_trigger_20030() -> bool:
	if ske.get_war_skill_val_int(ACTIVE_EFFECT_ID) <= 0:
		return false
	var dic = DataManager.get_env_dict("战争.攻击目标排除")
	dic[actorId] = ske.skill_name
	DataManager.set_env("战争.攻击目标排除", dic)
	return false

func on_trigger_20013() -> bool:
	ske.set_war_skill_val(0, 0, ACTIVE_EFFECT_ID)
	ske.remove_war_skill(actorId, "击免")
	return false

