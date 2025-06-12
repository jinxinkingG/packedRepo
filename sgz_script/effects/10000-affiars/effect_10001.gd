extends "effect_10000.gd"

#米道效果
#【米道】内政,锁定技。每月教众供奉：本城米+100，后备兵+50。

func on_trigger_10001()->bool:
	var cityId = self.get_working_city_id()
	if cityId < 0:
		return false

	var city = clCity.city(cityId)
	city.add_city_property("米", 100)
	city.add_city_property("后备兵", 50)

	return false
