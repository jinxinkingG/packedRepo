extends "effect_20000.gd"

#谲略效果
#【谲略】大战场，锁定技。准备阶段时，你的计策列表中各计策所消耗的机动力随机增加或减少0-2点，直到回合结束。

func on_trigger_20005()->bool:
	var dic = ske.get_war_skill_val_dic()
	var name = DataManager.get_env_str("计策.消耗.计策名")
	if not name in dic:
		return false
	var reduce = min(2, int(dic[name]))
	reduce = max(0, reduce)
	var cost = DataManager.get_env_int("计策.消耗.所需")
	if cost - reduce >= 2:
		DataManager.set_env("计策.消耗.所需", cost - reduce)
	return false

func on_trigger_20013()->bool:
	# 初始化减值
	var dic = {}
	for name in StaticManager.stratagemDic:
		dic[name] = randi() % 2
	ske.set_war_skill_val(dic, 1)
	return false
