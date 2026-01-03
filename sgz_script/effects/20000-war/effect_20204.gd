extends "effect_20000.gd"

# 度势效果
#【度势】大战场,锁定技。你的机动力为 0 时，恢复等同于你点数的机动力，之后刷新你点数。

func on_trigger_20031() -> bool:
	if me.action_point > 0:
		return false
	if me.poker_point == 0:
		return false

	var ap = ske.change_actor_ap(actorId, me.poker_point)
	me.refresh_poker_random()
	ske.war_report()

	var msg = "审时度势，寻机而动\n（【{0}】机动力恢复{1}".format([ske.skill_name, ap])
	me.attach_free_dialog(msg, 2)
	return false
