extends "effect_30000.gd"

#骑神锁定技 #骑兵强化
#【骑神】小战场，锁定技。非城战，你的战术持续期间，你的骑兵一回合可以行动3次。生效一次后失去此技能。

func on_trigger_30009()->bool:
	var buffed = false
	for buff in StaticManager.CONTINUOUS_TACTICS:
		if me.get_buff(buff)["回合数"] <= 0:
			continue
		buffed = true
		break
	if buffed:
		return false
	# 未找到任何小战场 buff, 尝试取消效果
	ske.set_battle_skill_val(0)
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled or bu.leaderId != actorId:
			continue
		if bu.get_unit_type() != "骑":
				continue
		if not bu.dic_combat.has(ske.skill_name):
			continue
		bu.dic_combat.erase(ske.skill_name)
		if bu.get_action_times() != 3:
			continue
		bu.set_action_times(2)
		# 回合切换期间，不需要关注 wait_action_times
	return false

func on_trigger_30010()->bool:
	for buff in StaticManager.CONTINUOUS_TACTICS:
		if me.get_buff(buff)["回合数"] <= 0:
			continue
		# 找到任意一个小战场 buff，尝试触发
		ske.set_battle_skill_val(1)
		var affected = 0
		for bu in DataManager.battle_units:
			if bu == null or bu.disabled or bu.leaderId != actorId:
				continue
			if bu.get_unit_type() != "骑":
				continue
			if bu.get_action_times() != 2:
				continue
			bu.dic_combat[ske.skill_name] = 1
			bu.set_action_times(3)
			bu.wait_action_times += 1
			affected += 1
		if affected > 0:
			DataManager.set_env("战术补充对话", "【{0}】发动\n感受铁蹄的力量吧！".format([ske.skill_name]))
			DataManager.set_env("战术补充对话表情", 0)
		break
	return false

func on_trigger_30099()->bool:
	if ske.get_battle_skill_val_int() > 0:
		ske.remove_war_skill(actorId, ske.skill_name)
	return false
