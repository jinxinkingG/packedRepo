extends "effect_10000.gd"

#佐命锁定效果
#【佐命】内政，锁定技。你非君主时，你方君主执行开发和防灾时，视为政99。

func on_trigger_10002()->bool:
	var cmd = DataManager.get_current_develop_command()
	if cmd.actionId == actorId:
		# 自己不生效
		return false
	if cmd.city().get_lord_id() != cmd.actionId:
		return false
	cmd.actionAttr = 99
	return true
