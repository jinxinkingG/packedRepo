extends "effect_20000.gd"

# 雅望效果
#【雅望】大战场，锁定技。每回合你的机动力额外+3。

func on_trigger_20013() -> bool:
	ske.change_actor_ap(actorId, 3)
	ske.war_report()
	return false
