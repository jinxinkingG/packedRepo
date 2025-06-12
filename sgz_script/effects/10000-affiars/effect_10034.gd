extends "effect_10000.gd"

#闲散锁定技
#【闲散】内政,锁定技。本月你没有执行过开发，策略，搜索，防灾时，次月你的经验+300。

const ORDERS = ["开发", "搜索", "防灾", "同盟", "毁盟", "离间", "招揽", "策反"]
const EXP_GAIN = 300

func check_trigger_correct() -> bool:
	var cityId = get_working_city_id()
	if cityId < 0:
		return false
	var city = clCity.city(cityId)
	if OrderHistory.orders_executed(city.get_vstate_id(), actorId, ORDERS):
		return false
	actor.add_exp(EXP_GAIN)
	return false
