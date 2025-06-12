extends "effect_20000.gd"

#盒酥被动效果
#【盒酥】大战场，主动技。你的下一次计策消耗由你方主将承担，若不足，由你的机动力补齐，每回合1次

func on_trigger_20004()->bool:
	var mainId = ske.get_war_skill_val_int()
	if mainId != me.get_main_actor_id():
		return false
	var mainWA = DataManager.get_war_actor(mainId)
	if mainWA == null or mainWA.disabled:
		return false
	if not check_env(["战争.计策列表", "战争.计策提示"]):
		return false
	var schemes = Array(get_env("战争.计策列表"))
	var msg = str(get_env("战争.计策提示"))
	var msgs = Array(msg.split("\n"))
	msgs.append("{0}提供额外{1}机动力".format([
		mainWA.get_name(), mainWA.action_point,
	]))
	msg = "\n".join(msgs.slice(0, 2))
	change_stratagem_list(me.actorId, schemes, msg)
	return false

func on_trigger_20005()->bool:
	var mainId = ske.get_war_skill_val_int()
	if mainId != me.get_main_actor_id():
		return false
	var mainWA = DataManager.get_war_actor(mainId)
	if mainWA == null or mainWA.disabled:
		return false
	var cost = get_env_int("计策.消耗.所需")
	var actual = get_env_int("计策.消耗.当前")
	if get_env_int("计策.消耗.仅对比") == 1:
		if actual + mainWA.action_point >= cost:
			actual = actual + min(cost, mainWA.action_point)
			set_env("计策.消耗.当前", actual)
		return false

	var se = DataManager.get_current_stratagem_execution()
	se.goback_disabled = 1
	var reduced = ske.change_actor_ap(mainWA.actorId, -cost)
	set_scheme_ap_cost("ALL", cost + reduced)
	var msg = "{0}代为消耗{1}机动力".format([
		mainWA.get_name(), abs(reduced),
	])
	se.append_result(ske.skill_name, msg, reduced, mainWA.actorId)
	ske.set_war_skill_val(0, 0)
	return false
