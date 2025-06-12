extends "effect_20000.gd"

#享乐锁定技
#【享乐】大战场，主将锁定技。你方存在其他武将的场合，敌将攻击你时，所需机动力翻倍；否则，敌将攻击你时至多需要1点机动力。

func on_trigger_20014() -> bool:
	var setting = get_env_dict("战争.攻击消耗")
	if int(setting["攻击目标"]) != me.actorId:
		return false
	if me.get_main_actor_id() != me.actorId:
		return false
	if get_teammate_targets(me, 999).size() > 0:
		# 存在其他武将
		if setting["固定"] >= 0:
			setting["固定"] = int(setting["固定"]) * 2
		else:
			setting["固定"] = int(setting["初始"]) * 2
	else:
		# 否则
		if setting["固定"] > 0:
			setting["固定"] = -1
		setting["至多"] = 1
	set_env("战争.攻击消耗", setting)
	return false
