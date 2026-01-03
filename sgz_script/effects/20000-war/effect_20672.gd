extends "effect_20000.gd"

# 略守效果
#【略守】大战场，主将锁定技。你攻击和用计所需机动力翻倍，敌将攻击你所需的机动力翻倍。

func on_trigger_20005() -> bool:
	var dic = ske.get_war_skill_val_dic()
	var settings = DataManager.get_env_dict("计策.消耗")
	var name = settings["计策"]
	var cost = int(settings["所需"])
	cost = cost * 2
	raise_scheme_ap_cost("ALL", cost)
	return false

func on_trigger_20014() -> bool:
	var setting = DataManager.get_env_dict("战争.攻击消耗")
	var fromId = int(setting["攻击来源"])
	var targetId = int(setting["攻击目标"])
	if not actorId in [fromId, targetId]:
		# 必须是我攻击或攻击我
		return false
	var ap = int(setting["初始"])
	var least = int(setting["至少"])
	setting["至少"] = int(max(least, ap * 2))
	DataManager.set_env("战争.攻击消耗", setting)
	return false
