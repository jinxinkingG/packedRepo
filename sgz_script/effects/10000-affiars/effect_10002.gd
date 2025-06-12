extends "effect_10000.gd"

#明政效果
#【明政】内政,锁定技。每月民忠+5，民忠100时，每月+200经验

func on_trigger_10001()->bool:
	var cityId = get_working_city_id()
	if cityId < 0:
		return false
	var city = clCity.city(cityId)
	if city.add_loyalty(5) <= 0:
		actor.add_exp(200)
	return false
