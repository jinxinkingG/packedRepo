extends "effect_20000.gd"

#恩怨锁定效果 #施加状态
#【恩怨】大战场，锁定技。你被自身以外的武将赋予任何状态时，对来源将领赋予相同状态。

func on_trigger_20022() -> bool:
	var buffKey = "BUFF.{0}".format([actorId])
	var buffName = DataManager.get_env_str(buffKey)
	var buffDecFlagKey = "BUFF.DEC.{0}".format([actorId])
	if DataManager.get_env_int(buffDecFlagKey) > 0:
		# 回合减少，不发动
		return false
	if me == null or me.disabled:
		return false
	var buff = me.get_buff(buffName)
	var buffTurns = int(buff["回合数"])
	if buffTurns <= 0:
		# 无此 buff，不发动
		return false
	var fromId = int(buff["来源武将"])
	if fromId < 0 or fromId == actorId:
		# 没找到来源，或者来源是自己，不发动
		return false
	var fromWA = DataManager.get_war_actor(fromId)
	if fromWA == null or fromWA.disabled:
		return false
	if fromWA.get_buff(buffName)["回合数"] > 0:
		# 对方已经有同样的 buff，不发动
		return false
	ske.set_war_buff(fromId, buffName, buffTurns)
	# 仅记录日志
	ske.war_report()
	var msg = "{0}为人，恩怨分明！\n（{1}被施加 [{2}]x{3}".format([
		DataManager.get_actor_self_title(actorId),
		fromWA.get_name(), buffName, buffTurns,
	])
	me.attach_free_dialog(msg, 0)
	return false

