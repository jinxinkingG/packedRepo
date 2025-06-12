extends "effect_20000.gd"

#长风锁定效果
#【长风】大战场，锁定技。你用计/被用计时，以你的“统”代替“知”计算那次计策的命中率和效果。

func on_trigger_20017()->bool:
	var se = DataManager.get_current_stratagem_execution()
	var diff = actor.get_leadership() - actor.get_wisdom()
	if diff <= 0:
		return false
	if ske.actorId == actorId and se.get_action_id(actorId) == actorId:
		# 触发自己，是我用计
		change_scheme_chance(me.actorId, ske.skill_name, diff)
	elif se.targetId == actorId and se.get_action_id(actorId) == ske.actorId:
		# 触发敌方，目标是我
		DataManager.set_env("计策.ONCE.目标智力", actor.get_leadership())
	return false

func on_trigger_20029()->bool:
	var se = DataManager.get_current_stratagem_execution()
	var diff = actor.get_leadership() - actor.get_wisdom()
	if diff <= 0:
		return false
	if ske.actorId == actorId and se.get_action_id(actorId) == actorId:
		# 触发自己，是我用计
		change_scheme_chance(me.actorId, ske.skill_name, diff)
	elif se.targetId == actorId and se.get_action_id(actorId) == ske.actorId:
		# 触发敌方，目标是我
		DataManager.set_env("计策.ONCE.目标智力", actor.get_leadership())
	return false
