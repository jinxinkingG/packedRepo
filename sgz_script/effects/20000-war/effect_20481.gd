extends "effect_20000.gd"

#骄黠锁定效果 #体力
#【骄黠】大战场，锁定技。结束阶段，你恢复X点体力值（X=你的剩余机动力/4）。

func on_trigger_20016()->bool:
	var recover = int(me.action_point / 4)
	if recover <= 0:
		return false
	ske.change_actor_hp(actorId, recover)
	ske.war_report()
	return false
