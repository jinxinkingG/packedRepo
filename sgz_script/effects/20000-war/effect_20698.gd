extends "effect_20000.gd"

# 恃险效果
#【恃险】大战场，主将锁定技。你为战争守方，你方势力城池数不大于3座时，你方任何武将满足“在至少2名敌将的计策范围之内”的条件，才能被指定为攻击目标。

func on_trigger_20030() -> bool:
	if clCity.all_city_ids([me.vstateId]).size() > 3:
		return false
	var excludedTargets = DataManager.get_env_dict("战争.攻击目标排除")
	var distance = DataManager.get_env_int("战争.攻击距离")
	var checking = me.get_teammates(false, true)
	# 用火计模拟测试一下
	var scheme = StaticManager.get_stratagem("火计")
	checking.append(me)
	var from = DataManager.get_war_actor(ske.actorId)
	for wa in checking:
		if wa.actorId in excludedTargets or str(wa.actorId) in excludedTargets:
			continue
		# 用距离减少检查量
		if Global.get_distance(wa.position, from.position) > distance:
			continue
		# 范围内如果有足够多的敌军，就别检测计策实际范围了
		if get_enemy_targets(wa, true, 6).size() >= 2:
			continue
		var enemyIds = get_enemy_targets(wa, true, 999)
		if enemyIds.size() < 2:
			# 人一共也没那么多，就不用检测计策实际范围了
			excludedTargets[wa.actorId] = ske.skill_name
			continue
		var touchableCnt = 0
		for enemyId in enemyIds:
			var enemy = DataManager.get_war_actor(enemyId)
			var d = Global.get_distance(enemy.position, wa.position)
			if d <= 6:
				touchableCnt += 1
				if touchableCnt >= 2:
					break
				continue
			DataManager.unset_env("计策.ONCE.距离")
			SkillHelper.auto_trigger_skill(enemy.actorId, 20026)
			if d <= scheme.get_fixed_targeting_range(enemy):
				touchableCnt += 1
				if touchableCnt >= 2:
					break
		if touchableCnt < 2:
			excludedTargets[wa.actorId] = ske.skill_name
	DataManager.set_env("战争.攻击目标排除", excludedTargets)
	return false
