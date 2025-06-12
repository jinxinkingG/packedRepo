extends "effect_20000.gd"

#密计效果
#【密计】大战场,锁定技。你所发动的伤兵计策，对自身之外的武将均视为没有计策来源。

func on_trigger_20018()->bool:
	# 用计执行前
	var se = DataManager.get_current_stratagem_execution()
	se.set_actioner(me.actorId, true)
	return false

