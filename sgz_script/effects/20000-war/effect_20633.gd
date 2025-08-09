extends "effect_20000.gd"

# 补牢锁定技
#【补牢】大战场，锁定技。若你方场上的武将数≥2，同一回合你只能被发起攻击宣言1次。

func on_trigger_20030() -> bool:
	var excludedTargets = DataManager.get_env_dict("战争.攻击目标排除")
	if me.get_teammates(false, true).empty():
		return false
	if me.get_day_defended_actors(wf.date).empty():
		return false
	excludedTargets[actorId] = ske.skill_name
	DataManager.set_env("战争.攻击目标排除", excludedTargets)
	return false
