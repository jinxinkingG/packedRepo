extends "effect_10000.gd"

#【联姻】内政，转换技·锁定。若你在刘备势力，你永久转为<阴>面，你每月经验+100
#【返乡】内政，转换技·锁定。若你不在刘备势力，你永久转为<阳>面，每月经验+100

func check_trigger_correct()->bool:
	var cityId = get_working_city_id()
	if cityId < 0:
		return false
	var city = clCity.city(cityId)
	var actor = ActorHelper.actor(self.actorId)
	if city.get_vstate_id() == StaticManager.VSTATEID_LIUBEI:
		actor.set_face(false)
	else:
		actor.set_face(true)
	actor.add_exp(100)
	return false
