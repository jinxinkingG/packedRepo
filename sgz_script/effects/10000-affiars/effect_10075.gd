extends "effect_10000.gd"

#秉壹锁定技
#【秉壹】内政，锁定技。若你当前所在势力为你的“初次加入势力”，你的忠诚度至少为80。

func on_trigger_10001()->bool:
	var cityId = get_working_city_id()
	if cityId < 0:
		return false

	var city = clCity.city(cityId)
	var vstateId = city.get_vstate_id()
	actor.set_initial_vstate_id(vstateId)
	if actor.get_loyalty() >= 80:
		return false
	var originalVstateId = actor.get_initial_vstate_id()
	if originalVstateId != vstateId:
		return false
	actor.set_loyalty(80)
	return false
