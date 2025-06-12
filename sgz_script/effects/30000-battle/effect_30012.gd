extends "effect_30000.gd"

#鼓舞效果实现

func on_trigger_30008():
	# 选择了哪个战术，靠调用此技能触发前的环境变量
	var tactic = DataManager.get_env_str("值")
	var cost = DataManager.get_env_int("战术消耗")
	if tactic == "" or cost <= 0:
		return false
	ske.battle_cd(99999)
	ske.battle_change_tactic_point(cost)
	ske.battle_report()
	return false
