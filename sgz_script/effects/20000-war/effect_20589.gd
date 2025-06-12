extends "effect_20000.gd"

# 读星效果
#【读星】大战场，锁定技。你方武将的用计距离+1，超出6格时按6格处理。该技能于场上存在多个时，效果不叠加。

func on_trigger_20026() -> bool:
	var rangeVal = 1
	var distanceVal = 6
	var changed = ske.get_war_skill_val_int_array()
	if changed.size() == 2:
		rangeVal = changed[0]
		distanceVal = changed[1]
	var setting = DataManager.get_env_dict("计策.ONCE.距离")
	for scheme in StaticManager.stratagems:
		if scheme.get_targeting_range(null) != 6:
			continue
		setting[scheme.name] = {
			"范围修正": rangeVal,
			"最大距离": distanceVal,
		}
	DataManager.set_env("计策.ONCE.距离", setting)
	return false
