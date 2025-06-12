extends "effect_20000.gd"

#护卫锁定技
#【护卫】大战场，锁定技。你的兵力不低于800时：若你有且只有一名相邻的本方武将，敌人不能攻击该武将。

func on_trigger_20030()->bool:
	if actor.get_soldiers() < 800:
		return false
	var teammates = get_teammate_targets(me, 1)
	if teammates.size() != 1:
		return false
	var excludedTargets = DataManager.get_env_dict("战争.攻击目标排除")
	excludedTargets[teammates[0]] = ske.skill_name
	DataManager.set_env("战争.攻击目标排除", excludedTargets)
	return false
