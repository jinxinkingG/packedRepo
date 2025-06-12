extends "effect_10000.gd"

#水利效果
#【水利】内政,锁定技。每月你所在城防灾+10，当防灾99时，你每月经验+250

func check_trigger_correct()->bool:
	var cityId = self.get_working_city_id()
	if cityId < 0:
		return false
	if clCity.add_city_property(cityId, "防灾", 10) == 0:
		var actor = ActorHelper.actor(self.actorId)
		actor.add_exp(250)
	return false
