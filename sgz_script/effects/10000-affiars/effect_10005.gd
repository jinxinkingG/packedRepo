extends "effect_10000.gd"

#事半效果
#【事半】内政,锁定技。你执行开发行动时，所需金减半。

func on_trigger_10002()->bool:
	var cmd = DataManager.get_current_develop_command()
	if cmd.type == "防灾":
		return false
	cmd.costRate *= 0.5
	return false
