extends "effect_20000.gd"

# 甲眠锁定效果
#【甲眠】大战场，锁定技。合甲而眠，预防劫寨。你无法通过其他武将的技能效果进入白刃战；你对敌将或敌将对你发起攻击宣言时，所需的机动力-1（至少需1）。

func on_trigger_20014() -> bool:
	var setting = DataManager.get_env_dict("战争.攻击消耗")
	var fromId = int(setting["攻击来源"])
	var targetId = int(setting["攻击目标"])
	if not actorId in [fromId, targetId]:
		# 必须是我攻击或攻击我
		return false
	setting["减少"] = 1
	setting["至少"] = 1
	DataManager.set_env("战争.攻击消耗", setting)
	return false
