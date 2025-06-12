extends "effect_20000.gd"

#迅机效果
#【迅机】大战场，锁定技。你机动力为0的场合，你可无消耗移动， 此方式的移动每回合最多进行4次。

const LIMIT = 4

func on_trigger_20003()->bool:
	if me.action_point > 0:
		return false
	var steps = ske.get_war_skill_val_int()
	match DataManager.get_env_int("移动"):
		1: #移动1步
			var cost = DataManager.get_env_dict("移动消耗")
			if cost["机"] == 0 and cost["点"] == 0:
				steps = min(LIMIT, steps + 1)
				ske.set_war_skill_val(steps, 1)
		-1: #撤销1步
			steps = max(0, steps - 1)
			ske.set_war_skill_val(steps, 1)
	var msg = "（【{0}】:{1}/{2}".format([ske.skill_name, steps, LIMIT])
	var msgs = DataManager.get_env_str("对白").split("\n")
	if msgs.size() <= 2:
		msgs.append(msg)
	elif msgs.size() == 3:
		msgs[2] += "，" + msg.right(1)
	DataManager.set_env("对白", "\n".join(msgs))
	return false

func on_trigger_20007()->bool:
	if me.action_point > 0:
		return false
	var steps = ske.get_war_skill_val_int()
	if steps >= 4:
		return false
	set_max_move_ap_cost([], 0)
	return false
