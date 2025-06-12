extends "effect_10000.gd"

#仁德效果
#【仁德】内政，太守锁定技。同城武将，忠＜80时，每个月忠+4。

func on_trigger_10006()->bool:
	var cityId = get_working_city_id()
	if cityId < 0:
		return false
	ske.affair_cd(1)
	var city = clCity.city(cityId)
	for memberId in city.get_actor_ids():
		var member = ActorHelper.actor(memberId)
		if member.get_loyalty() < 80:
			member.set_loyalty(member.get_loyalty() + 4)
	return false
