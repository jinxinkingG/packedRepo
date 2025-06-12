extends "effect_10000.gd"

#善政效果
#【善政】内政,锁定技。每月你所在城产业+20，土地+20，你的经验+200

func check_trigger_correct()->bool:
	var cityId = self.get_working_city_id()
	if cityId < 0:
		return false

	var city = clCity.city(cityId)
	city.add_city_property("土地", 20)
	city.add_city_property("产业", 20)
	
	var actor = ActorHelper.actor(self.actorId)
	actor.add_exp(200)

	return false
