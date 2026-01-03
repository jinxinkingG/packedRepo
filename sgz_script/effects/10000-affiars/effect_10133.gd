extends "effect_10000.gd"

# 郡望锁定技
#【郡望】内政，太守锁定技。你所在城进行赏赐武将时：本城民忠+4。

const LOYALTY_BUFF = 4

func on_trigger_10012() -> bool:
	if DataManager.get_env_str("内政.命令") != "赏赐武将":
		return false
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var added = city.add_loyalty(LOYALTY_BUFF)
	if added > 0:
		var msg = "{0}干城也，民心可安\n（【{1}】效果\n（统治度上升{2}，现为{3}".format([
			DataManager.get_actor_honored_title(ske.actorId, actorId),
			ske.skill_name, added, city.get_loyalty(),
		])
		city.attach_free_dialog(msg, actorId, 1)
	return false
