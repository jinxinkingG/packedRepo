extends "effect_10000.gd"

#纳蛮效果
#【纳蛮】内政，锁定技。你位于永昌、建宁时，奉命征讨南蛮，每月人口+300，经验+200。

func on_trigger_10001()->bool:
	var cityId = get_working_city_id()
	if cityId < 0:
		return false
	var city = clCity.city(cityId)
	if not city.has_feature("蛮"):
		return false
	city.add_city_property("人口", 300)
	actor.add_exp(200)
	return false
