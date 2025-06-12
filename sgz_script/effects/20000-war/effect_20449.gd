extends "effect_20000.gd"

#夜辨锁定技
#【夜辨】大战场，锁定技。你只能和相邻的敌将进入白刃战。

func on_trigger_20030()->bool:
	var excludedTargets = DataManager.get_env_dict("战争.攻击目标排除")
	if ske.actorId == actorId:
		# 自己发起攻击
		for targetId in get_enemy_targets(me, 999):
			var wa = DataManager.get_war_actor(targetId)
			if Global.get_distance(wa.position, me.position) == 1:
				continue
			excludedTargets[wa.actorId] = ske.skill_name
		DataManager.set_env("战争.攻击目标排除", excludedTargets)
		return false
	# 被视为攻击对象
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or me == null:
		return false
	if Global.get_distance(wa.position, me.position) == 1:
		return false
	
	excludedTargets[actorId] = ske.skill_name
	DataManager.set_env("战争.攻击目标排除", excludedTargets)
	return false
