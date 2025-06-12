extends "effect_10000.gd"

#水训效果
#【水训】内政,锁定技。与你同城的水军，每月经验+100

func check_trigger_correct()->bool:
	var cityId = self.get_working_city_id()
	if cityId < 0:
		return false
	var city = clCity.city(cityId)
	for id in city.get_actor_ids():
		var actor = ActorHelper.actor(id)
		if actor.get_troops_type() == "水":
			actor.add_exp(100)
	return false
