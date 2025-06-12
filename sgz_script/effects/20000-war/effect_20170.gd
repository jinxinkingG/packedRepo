extends "effect_20000.gd"

#观星效果
#【观星】大战场,锁定技。你方武将用计时，你启用道术，使视野范围内的任何敌将与其距离均视为不超过6。

func on_trigger_20026():
	var setting = DataManager.get_env_dict("计策.ONCE.距离")
	for scheme in StaticManager.stratagems:
		if scheme.name == "火箭":
			continue
		if scheme.get_targeting_range(null) != 6:
			continue
		setting[scheme.name] = {
			"无限": 1,
			"最大距离": 6,
		}
	DataManager.set_env("计策.ONCE.距离", setting)
	return false
