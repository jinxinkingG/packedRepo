extends "effect_10000.gd"

# 降琬效果
#【降琬】内政，锁定技。天降瑞星，若山出美玉；地育贤才，如海纳明珠。你所在势力君主的“德”不低于85，则你在搜索时，有一定概率搜到全地图流放状态的武将。

func on_trigger_10017() -> bool:
	var city = clCity.city(get_working_city_id())
	var lord = ActorHelper.actor(city.get_lord_id())
	if lord.get_moral() < 85:
		return false
	var cmd = DataManager.get_current_search_command()
	var original = cmd.result
	# 已经找到人，忽略
	if original in [5,6,7]:
		return false
	# 30% 概率
	if not Global.get_rate_result(30):
		return false
	# 看看全国范围内有没有人
	var exiled = ActorHelper.all_exiled_actors()
	if exiled.empty():
		return false
	exiled.shuffle()
	cmd.result = 5
	# 指定搜索
	cmd.specifiedFoundActorId = exiled[0].actorId
	return false
