extends "effect_10000.gd"

#郡守锁定技
#【郡守】内政，太守锁定技。同城其他武将执行内政开发时（包括，开发土地，产业，人口，防灾），你的经验+150

const EXP_BONUS = 150

func on_trigger_10019() -> bool:
	if ske.actorId == actorId:
		# 自己不触发
		return false
	var cityId = get_working_city_id()
	if cityId < 0:
		return false
	var city = clCity.city(cityId)
	if city.get_leader_id() != actorId:
		return false
	var added = actor.add_exp(EXP_BONUS)
	if added > 0:
		var msg = "{0}勤勉，吾亦感佩\n（【{1}】获得经验 {2}".format([
			DataManager.get_actor_honored_title(ske.actorId, actorId),
			ske.skill_name, added
		])
		city.attach_free_dialog(msg, actorId, 1)
	return false
