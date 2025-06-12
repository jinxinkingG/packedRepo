extends "effect_20000.gd"

#玄知锁定技
#【玄知】大战场，锁定技。你使用/被使用伤兵计时，若受计者的五行被用计者克制，无视命中率直接结算伤害。注：木克土，土克水，水克火，火克金，金克木

func on_trigger_20010()->bool:
	# 计策计算命中率前
	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	var fromId = -1
	var targetId = -1
	if se.get_action_id(actorId) == actorId:
		# 是用计者
		fromId = actorId
		targetId = se.targetId
	elif se.targetId == actorId:
		# 是计策目标
		fromId = se.get_action_id(actorId)
		targetId = actorId
	else:
		return false
	var from = DataManager.get_war_actor(fromId)
	var target = DataManager.get_war_actor(targetId)
	if from == null or target == null:
		return false
	if not from.five_phases_against(target):
		return false
	se.set_must_success(actorId, ske.skill_name)
	return false

func on_trigger_20026()->bool:
	# 选择计策目标前
	# 为每个敌军标记临时相生相克
	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	if se.get_action_id(actorId) == actorId:
		# 是用计者
		for targetId in get_enemy_targets(me, true, 999):
			var wa = DataManager.get_war_actor(targetId)
			if me.five_phases_against(wa):
				wa.set_tmp_variable("五行克制", actorId)
			else:
				wa.set_tmp_variable("五行克制", 0)
	else:
		# 是潜在计策目标
		var wa = DataManager.get_war_actor(ske.actorId)
		if wa.five_phases_against(me):
			me.set_tmp_variable("五行克制", wa.actorId)
		else:
			me.set_tmp_variable("五行克制", 0)
	return false
