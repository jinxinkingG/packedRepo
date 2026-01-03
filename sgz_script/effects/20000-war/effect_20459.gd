extends "effect_20000.gd"

#谲略效果
#【谲略】大战场，锁定技。准备阶段时，你的计策列表中各计策所消耗的机动力随机增加或减少0-2点，直到回合结束。

func on_trigger_20004() -> bool:
	var dic = ske.get_war_skill_val_dic()
	var schemes = DataManager.get_env_array("战争.计策列表")
	for scheme in schemes:
		if scheme[0] in dic and dic[scheme[0]] > 0 and scheme[2] == "":
			pass
			# 多个技能会冲突，再想想
			#scheme[2] = ske.skill_name
	change_stratagem_list(actorId, schemes)
	return false

func on_trigger_20005() -> bool:
	var dic = ske.get_war_skill_val_dic()
	var settings = DataManager.get_env_dict("计策.消耗")
	var name = settings["计策"]
	var cost = int(settings["所需"])
	if not name in dic:
		return false
	var reduce = min(2, int(dic[name]))
	reduce = max(0, reduce)
	if cost - reduce >= 2:
		reduce_scheme_ap_cost(name, cost - reduce)
	return false

func on_trigger_20013() -> bool:
	# 初始化减值
	var dic = {}
	for name in StaticManager.stratagemDic:
		dic[name] = randi() % 2
	ske.set_war_skill_val(dic, 1)
	return false
