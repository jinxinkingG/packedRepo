extends "effect_20000.gd"

#无畏被动效果
#【无畏】大战场，锁定技。每有一个己方武将被击杀/被俘虏/撤退，你的体力+10。

const HP_RECOVER = 10

func on_trigger_20027()->bool:
	if not DataManager.get_env_str("战争.DISABLE.TYPE") in ["撤退", "俘虏", "阵亡"]:
		return false
	var recover = ske.change_actor_hp(actorId, HP_RECOVER)
	if recover <= 0:
		return false
	ske.war_report()
	var targetActor = ActorHelper.actor(ske.actorId)
	var msg = "{0}战虽不利\n正当吾用兵之时！\n（【{1}】体力回复 {2}".format([
		DataManager.get_actor_honored_title(ske.actorId, actorId),
		ske.skill_name, recover,
	])
	me.attach_free_dialog(msg, 0)
	return false
