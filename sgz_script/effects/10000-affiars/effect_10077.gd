extends "effect_10000.gd"

#宗祚效果，命令书保底
#【宗祚】内政，君主锁定技。若刘辩、刘协至少一人为出仕状态，且均不在你方城池中时：你所在势力的命令书至少为4。

func on_trigger_10001():
	if DataManager.orderbook >= 4:
		return false
	var emporerOutside = false
	for targetId in [StaticManager.ACTOR_ID_LIUBIAN, StaticManager.ACTOR_ID_LIUXIE]:
		var yourMajesty = ActorHelper.actor(targetId)
		if not yourMajesty.is_status_officed():
			continue
		var cityId = DataManager.get_office_city_by_actor(targetId)
		if cityId < 0:
			continue
		if clCity.city(cityId).get_lord_id() == actorId:
			continue
		emporerOutside = true
		break
	if not emporerOutside:
		return false
	DataManager.orderbook = max(4, DataManager.orderbook)
	return false
