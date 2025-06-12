extends "effect_10000.gd"

#名医效果
#【名医】内政,锁定技。你的[药]初始数量为100，每月你的[药]+（10+等级*2），经验+100。你带兵上限为默认为500

const FLAG_NAME = "药"

func on_trigger_10001()->bool:
	ske.affair_cd(1)
	var flags = ske.get_skill_flags(10000, ske.effect_Id, FLAG_NAME)
	var added = 0
	if flags == 0:
		# 判断是否初始状态
		var skv = SkillHelper.get_skill_variable(10000, ske.effect_Id, actorId)
		if skv["turn"] <= 0 or skv["value"] == null:
			added = 100
	added += 10 + 2 * actor.get_level()
	ske.add_skill_flags(10000, ske.effect_Id, FLAG_NAME, added)
	ItemHelper.getItem(0).incCount(actorId, 2)
	actor.add_exp(100)
	return false

func on_trigger_20034()->bool:
	return on_trigger_10001()
