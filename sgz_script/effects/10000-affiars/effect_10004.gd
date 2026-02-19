extends "effect_10000.gd"

# 水训效果
#【水训】内政,锁定技。与你同城的水军，每月经验+100

const TROOPS_TYPE = "水"

func on_trigger_10001() -> bool:
	var cityId = get_working_city_id()
	if cityId < 0:
		return false
	var city = clCity.city(cityId)
	for actorId in city.get_actor_ids():
		var a = ActorHelper.actor(actorId)
		if a.get_troops_type() == TROOPS_TYPE:
			a.add_exp(100)
	return false
