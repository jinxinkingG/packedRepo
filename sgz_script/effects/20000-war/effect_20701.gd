extends "effect_20000.gd"

# 旋略效果
#【旋略】大战场，锁定技。你的机动力消耗至0时，执行1次机动力恢复，每2回合限1次。

func on_trigger_20031() -> bool:
	if me.action_point > 0:
		return false

	me.action_point = 0
	me.recharge_action_point()
	var ap = me.action_point
	# 回写当前机动力
	me.action_point = 0
	ap = ske.change_actor_ap(actorId, ap)
	ske.cost_war_cd(2)
	ske.war_report()

	var msg = "旋灭旋生，随势而动\n（【{0}】机动力恢复{1}".format([ske.skill_name, ap])
	me.attach_free_dialog(msg, 2)
	return false
