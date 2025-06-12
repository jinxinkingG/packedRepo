extends "effect_10000.gd"

#战名效果
#【战名】内政,锁定技。你所在城，每月后备兵+200

func check_trigger_correct()->bool:
	var cityId = self.get_working_city_id()
	if cityId < 0:
		return false
	clCity.add_city_property(cityId, "后备兵", 200)
	return false
