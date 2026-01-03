extends "effect_10000.gd"

# 游历
#【游历】内政，锁定技。执行内政指令一无所获时，经验+200。（包括搜索空手而回，同盟、离间、招揽、策反失败）

const EXP_GAIN = 200

func on_trigger_10012() -> bool:
	match DataManager.get_env_str("内政.命令"):
		"搜索":
			var cmd = DataManager.get_current_search_command()
			if cmd.result != 8:
				return false
		"策略":
			var cmd = DataManager.get_current_policy_command()
			if cmd.result != 0:
				return false
		_:
			return false
	var added = ske.change_actor_exp(actorId, EXP_GAIN)
	if added <= 0:
		return false
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var msg = "也算是一番历练 … …\n（【{0}】经验 +{1}".format([
		ske.skill_name, added,
	])
	city.attach_free_dialog(msg, actorId)
	return false
