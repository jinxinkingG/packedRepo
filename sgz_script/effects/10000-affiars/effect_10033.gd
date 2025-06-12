extends "effect_10000.gd"

#说盟锁定技
#【说盟】内政,锁定技。你被派遣执行“同盟”指令时，成功率+10%，花费的金米数减半。

const KEY_RATE = "内政.同盟成功率"
const KEY_COST = "内政.同盟花费"

func check_trigger_correct() -> bool:
	if not check_env([KEY_RATE, KEY_COST]):
		return false
	var rate = int(get_env(KEY_RATE))
	var cost = int(get_env(KEY_COST))
	set_env(KEY_RATE, min(100, rate + 10))
	set_env(KEY_COST, int(cost / 2))
	return false
