extends "effect_10000.gd"

#功倍效果
#【功倍】内政,锁定技。你执行开发行动时，所需金为2倍，效果为1.5倍。

func on_trigger_10002()->bool:
	var cmd = DataManager.get_current_develop_command()
	if cmd.type == "防灾":
		return false
	cmd.costRate *= 2.0
	cmd.effectRate *= 1.5
	return false
