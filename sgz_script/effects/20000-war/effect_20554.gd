extends "effect_20000.gd"

#勤计效果实现
#【勤计】大战场，锁定技。你每使用一次计策，不论成功与否，经验+50。

const EXP_GAIN = 50

func on_trigger_20009() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(actorId) != actorId:
		return false

	var added = ske.change_actor_exp(actorId, EXP_GAIN)
	var msg = "勤能补拙"
	if se.succeeded > 0:
		msg = "熟能生巧"
	msg += "，经验+{0}".format([added])
	if me.get_controlNo() < 0:
		msg = me.get_name() + msg
	se.append_result(ske.skill_name, msg, added, actorId)
	return false
