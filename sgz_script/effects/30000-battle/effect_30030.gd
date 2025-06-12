extends "effect_30000.gd"

#鼓战效果实现
#【鼓战】小战场,锁定技。你使用[挑衅]失败时，你体力+5，并获得3回合[士气向上]。

func on_trigger_30012():
	var bu = get_leader_unit(me.actorId)
	if bu == null:
		return false
	var turns = ske.set_battle_buff(me.actorId, "士气向上", 3)
	ske.battle_change_unit_hp(bu, 5)
	ske.battle_report()

	var msg = "无胆鼠辈，必为我所擒\n擂鼓，进军！\n（【{0}】获得{1}回合士气向上".format([
		ske.skill_name, turns,
	])
	me.attach_free_dialog(msg, 0, 30000)
	return false
