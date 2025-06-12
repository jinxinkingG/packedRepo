extends "effect_20000.gd"

#延祸锁定效果部分
#【延祸】大战场，主将限定技。敌方所有武将技能，直到本回合结束前禁用，你方所有武将机动力+5，并获得 {围困} 状态，持续到战争结束；该回合结束后，你方所有武将的技能直到战争结束前禁用。

const ACTIVE_EFFECT_ID = 20461

func on_trigger_20016()->bool:
	if ske.get_war_skill_val_int(ACTIVE_EFFECT_ID) <= 0:
		return false
	ske.set_war_buff(actorId, "沉默", 99999)
	for targetId in get_teammate_targets(me, 999):
		ske.set_war_buff(targetId, "沉默", 99999)
	var msg = "未竟全功，祸事至矣 ……\n（因【{0}】效果\n（我军全体技能被禁用".format([
		ske.skill_name,
	])
	me.attach_free_dialog(msg, 3)
	return false
