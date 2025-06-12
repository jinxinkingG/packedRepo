extends "effect_20000.gd"

#据势锁定技
#【据势】大战场，主将锁定技。你方武将在山地形时，可以进攻距离3以内的敌人。

func on_trigger_20030()->bool:
	var wa = DataManager.get_war_actor(ske.actorId)
	var terrian = map.get_blockCN_by_position(wa.position)
	if terrian != "山地":
		return false
	var rng = DataManager.get_env_int("战争.攻击距离")
	DataManager.set_env("战争.攻击距离", max(3, rng))
	return false
