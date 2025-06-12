extends "effect_20000.gd"

#备马锁定技
#【备马】大战场，锁定技。你每移动一步时，所需机动力-1，且至少消耗1。累计移动30步后，你失去本技能。

const STEPS_LIMIT = 30

func on_trigger_20003() -> bool:
	var times = ske.get_war_skill_val_int()
	var moveType = DataManager.get_env_int("移动")
	var moveStopped = DataManager.get_env_int("结束移动")
	var msg = DataManager.get_env_str("对白")
	if moveType == 0 and moveStopped > 0:
		if times >= STEPS_LIMIT:
			ske.remove_war_skill(actorId, ske.skill_name)
			ske.war_report()
		return false
	match moveType:
		1:
			times += 1
		-1:
			times -= 1
	ske.set_war_skill_val(times)
	var left = max(0, STEPS_LIMIT - times)
	if msg.split("\n").size() <= 2:
		msg += "\n【{0}】剩余： {1}步".format([ske.skill_name, left])
	DataManager.set_env("对白", msg)
	return false

func on_trigger_20007()->bool:
	var times = ske.get_war_skill_val_int()
	if times >= STEPS_LIMIT:
		return false
	reduce_move_ap_cost([], 1)
	return false
