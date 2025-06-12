extends "effect_10000.gd"

#收羌效果
#【收羌】内政，锁定技。你位于武威、天水、安定时，奉命收服羌族，每月人口+300，经验+200。

func on_trigger_10001()->bool:
	var cityId = get_working_city_id()
	if cityId < 0:
		return false
	var city = clCity.city(cityId)
	if not city.has_feature("羌"):
		return false
	city.add_city_property("人口", 300)
	actor.add_exp(200)
	return false
