extends "effect_20000.gd"

# 耐霜效果
#【耐霜】大战场，锁定技。你被指定为计策目标的场合：你的机动力+2。

func on_trigger_20009() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	if actorId != se.targetId:
		return false
	ske.change_actor_ap(actorId, 2)
	ske.war_report()
	return false
