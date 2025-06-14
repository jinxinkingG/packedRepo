extends "effect_10000.gd"

#说盟锁定技
#【说盟】内政,锁定技。你被派遣执行“同盟”指令时，成功率+10%，花费的金米数减半。

const KEY_COST = "内政.同盟花费"

func on_trigger_10010() -> bool:
	var cmd = DataManager.get_current_policy_command()
	if cmd.type != "同盟":
		return false
	cmd.rate = min(100, cmd.rate + 10)
	cmd.costRice = int(cmd.costRice / 2)
	cmd.costGold = int(cmd.costGold / 2)
	return false
