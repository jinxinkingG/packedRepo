extends "effect_10000.gd"

# 系望锁定技
#【系望】内政，太守锁定技。你所在城进行赏赐民众时：本城忠低于你且最低的武将之一忠诚+8。

func on_trigger_10025() -> bool:
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var leastLoyalty = 100
	var leastMember = null
	for memberId in city.get_actor_ids():
		var member = ActorHelper.actor(memberId)
		var loyalty = member.get_loyalty()
		if loyalty >= actor.get_loyalty():
			continue
		if loyalty < leastLoyalty:
			leastLoyalty = loyalty
			leastMember = member
	if leastMember != null:
		var added = leastMember.add_loyalty(8)
		var msg = "{0}真不负众望者也\n（【{1}】效果\n（{2}忠诚度 +{3}".format([
			DataManager.get_actor_honored_title(actorId, leastMember.actorId),
			ske.skill_name, leastMember.get_name(), added])
		city.attach_free_dialog(msg, leastMember.actorId, 1)
	return false
