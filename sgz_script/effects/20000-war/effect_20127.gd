extends "effect_20000.gd"

#智计
#【智计】大战场,锁定技。你使用计策每成功一次，你的[智]标记+1，上限x个，你的计策命中率+[智]标记数%，x=（你的等级*2-1）

func on_trigger_20017() -> bool:
	var x = ske.get_war_skill_val_int()
	if x <= 0:
		return false
	change_scheme_chance(actorId, ske.skill_name, x)
	return false

func on_trigger_20004() -> bool:
	var x = ske.get_war_skill_val_int()
	var schemes = DataManager.get_env_array("战争.计策列表")
	var msg = DataManager.get_env_str("战争.计策提示")
	var msgs = Array(msg.split("\n"))
	msgs.append("（本回合[智计]: {0}".format([x]))
	msg = "\n".join(msgs.slice(0, 2))
	change_stratagem_list(actorId, schemes, msg)
	return false

func on_trigger_20009() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.succeeded <= 0:
		return false
	if se.get_action_id(actorId) != actorId:
		return false
	var x = ske.get_war_skill_val_int()
	var maxX = actor.get_level() * 2 - 1
	x = min(x + 1, maxX)
	ske.set_war_skill_val(x)
	return false
