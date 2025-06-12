extends "effect_10000.gd"

#收越效果
#【收越】内政，锁定技。你位于建安、会稽、夷洲时，奉命收服山越，每月人口+300，经验+200。

func on_trigger_10001()->bool:
	var cityId = get_working_city_id()
	if cityId < 0:
		return false
	var city = clCity.city(cityId)
	if not city.has_feature("越"):
		return false
	city.add_city_property("人口", 300)
	actor.add_exp(200)
	return false
