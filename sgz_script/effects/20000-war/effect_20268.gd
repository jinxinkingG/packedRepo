extends "effect_20000.gd"

#盒酥被动效果
#【盒酥】大战场，主动技。你的下一次计策消耗由你方主将承担，若不足，由你的机动力补齐，每回合1次

func on_trigger_20004() -> bool:
	var leader = me.get_leader()
	if leader == null or leader.disabled:
		return false
	if leader.actorId != ske.get_war_skill_val_int():
		return false

	var schemes = DataManager.get_env_array("战争.计策列表")
	var msg = DataManager.get_env_str("战争.计策提示")
	var msgs = Array(msg.split("\n"))
	msgs.append("{0}提供额外{1}机动力".format([
		leader.get_name(), leader.action_point,
	]))
	msg = "\n".join(msgs.slice(0, 2))
	change_stratagem_list(actorId, schemes, msg)
	return false

func on_trigger_20005() -> bool:
	var leader = me.get_leader()
	if leader == null or leader.disabled:
		return false
	if leader.actorId != ske.get_war_skill_val_int():
		return false

	var settings = DataManager.get_env_dict("计策.消耗")
	var name = settings["计策"]
	var cost = int(settings["所需"])
	var current = int(settings["当前"])
	# 修改当前值，视为与主将机动力加一起，判断是不是能发动
	settings["当前"] = current + leader.action_point
	DataManager.set_env("计策.消耗", settings)
	return false

func on_trigger_20006() -> bool:
	var leader = me.get_leader()
	if leader == null or leader.disabled:
		return false
	if leader.actorId != ske.get_war_skill_val_int():
		return false

	ske.set_war_skill_val(0, 0)
	var se = DataManager.get_current_stratagem_execution()
	se.goback_disabled = 1

	var settings = DataManager.get_env_int_array("计策.扣减")
	var cost = settings[0]
	var prev = settings[1]
	var current = settings[2]

	# 这时，current + cost = 主将当前 ap + 我之前的 ap
	# prev 应修正成我之前的 ap
	# current 应修正成我发动后应留的 ap
	prev = current + cost - leader.action_point
	var reduced = cost
	if leader.action_point >= cost:
		# 主将代扣，我的 ap 还原
		leader.action_point -= cost
		current = prev
	else:
		reduced = leader.action_point
		leader.action_point = 0
		current = prev + reduced - cost
	DataManager.set_env("计策.扣减", [cost, prev, current])

	var msg = "{0}代为消耗{1}机动力".format([
		leader.get_name(), reduced,
	])
	se.append_result(ske.skill_name, msg, reduced, leader.actorId)
	return false
