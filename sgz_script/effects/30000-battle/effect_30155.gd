extends "effect_30000.gd"

#绊绳锁定技
#【绊绳】小战场,锁定技。你使用「咒缚」需4点战术，同时必定成功，持续回合+1。

func on_trigger_30005()->bool:
	me.dic_other_variable["咒缚额外消耗"] = 1
	return false

func on_trigger_30099()->bool:
	me.dic_other_variable.erase("咒缚额外消耗")
	return false

func on_trigger_30008()->bool:
	if enemy == null:
		return false
	if DataManager.get_env_str("值") != "咒缚":
		return false
	DataManager.set_env("结果", 1)
	DataManager.set_env("战斗.战术接管", 1)
	var turns = me.set_buff("咒缚", 4, me.actorId, ske.skill_name)
	if me.get_controlNo() < 0:
		var msg = "{0}发动【{1}】\n被咒止{2}(+1)回合".format([
			me.get_name(), ske.skill_name, turns - 1
		])
		enemy.attach_free_dialog(msg, 3, 30000)
	else:
		var msg = "【{0}】发动\n{1}被咒止{2}(+1)回合".format([
			ske.skill_name, enemy.get_name(), turns - 1
		])
		me.attach_free_dialog(msg, 1, 30000)
	return false
