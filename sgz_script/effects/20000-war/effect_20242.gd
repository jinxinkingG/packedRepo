extends "effect_20000.gd"

#城击锁定技
#【城击】大战场，锁定技。你在城地形时，你可以消耗5点机动力，对距离2以内的非城地形敌人，发起攻击宣言。

const COST_AP = 5

func on_trigger_20014() -> bool:
	# 计算攻击消耗机动力
	var dic = DataManager.get_env_dict("战争.攻击消耗")
	if dic.empty():
		return false
	var fromId = Global.intval(dic["攻击来源"])
	var targetId = Global.intval(dic["攻击目标"])
	if fromId != actorId:
		return false
	var targetWA = DataManager.get_war_actor(targetId)
	if targetWA == null or targetWA.disabled:
		return false
	if Global.get_distance(targetWA.position, me.position) == 2:
		dic["固定"] = COST_AP
		set_env("战争.攻击消耗", dic)
	return false

func on_trigger_20030() -> bool:
	var blockCN = map.get_blockCN_by_position(me.position)
	if not blockCN in StaticManager.CITY_BLOCKS_CN:
		return false
	if me.action_point < COST_AP:
		return false
	DataManager.set_env("战争.目标地形排除", StaticManager.CITY_BLOCKS_CN.duplicate())
	DataManager.set_env("战争.攻击距离", 2)
	return false
