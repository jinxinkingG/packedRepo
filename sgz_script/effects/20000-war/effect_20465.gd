extends "effect_20000.gd"

#渐军锁定技 #移动
#【渐军】大战场，锁定技。你移动所需的机动力-1(至少为1)，但每回合移动的步数不能超过6步。

const STEPS_LIMIT = 6

func on_trigger_20003()->bool:
	var steps = ske.get_war_skill_val_int()
	match DataManager.get_env_int(KEY_MOVE_TYPE):
		1:
			steps += 1
		-1:
			steps -= 1
	ske.set_war_skill_val(steps, 1)
	var msg = DataManager.get_env_str("对白")
	if msg.split("\n").size() <= 2:
		var left = max(0, STEPS_LIMIT - steps)
		msg += "\n【{0}】限行：{1}步".format([ske.skill_name, left])
		DataManager.set_env("对白", msg)
	return false

func on_trigger_20007()->bool:
	var steps = ske.get_war_skill_val_int()
	if steps >= STEPS_LIMIT:
		DataManager.set_env(KEY_MOVE_AP_COST, 9999)
		return false
	var ap = DataManager.get_env_int(KEY_MOVE_AP_COST)
	if ap <= 1:
		return false
	reduce_move_ap_cost([], 1)
	return false
