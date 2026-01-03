extends "effect_20000.gd"

# 定变锁定技
#【定变】大战场，锁定技。你获得负面状态时，若机动力＞0，自动清空机动力并防止之。

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
	if not StaticManager.get_buff(buffName).is_negative():
		return false
	if me.action_point <= 0:
		return false
	# 尝试解除计策的连策
	var se = DataManager.get_current_stratagem_execution()
	se.skip_redo = 1
	ske.change_actor_ap(actorId, -me.action_point)
	ske.remove_war_buff(actorId, buffName)
	ske.war_report()
	var msg = "不动如山，何隙可乘\n（{0}【{1}】摆脱 [{2}]\n（机动力归零".format([
		actor.get_name(), ske.skill_name, buffName,
	])
	me.attach_free_dialog(msg, 2)
	return false

