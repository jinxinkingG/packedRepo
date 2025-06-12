extends "effect_30000.gd"

#孤胆对话
#你的武临时+x/2，胆+x，x为（12-你剩余机动力），最小为0，最大为12。

func on_trigger_30006():
	# 判断剩余机动力，若满足发动条件，触发孤胆
	var x = max(0, 12 - me.action_point)
	if x <= 0:
		return false

	# 加 buff
	var sbp = ske.get_battle_skill_property()
	sbp.courage += x
	sbp.power += int(x/2)
	ske.apply_battle_skill_property(sbp)
	ske.battle_report()

	var msg = "阵前有我{0}\n千军万马何惧！".format([
		DataManager.get_actor_self_title(me.actorId)
	])
	me.attach_free_dialog(msg, 0, 30000)
	return false
