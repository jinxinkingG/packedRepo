extends "effect_10000.gd"

# 合归锁定技
#【合归】内政，君主锁定技。你登为君主期间，每有一个势力灭亡，你的势力命令书额外+1，至多以此法增加3枚。

func on_trigger_10001() -> bool:
	var added = ske.affair_get_skill_val_int()
	DataManager.orderbook += added
	return false

func on_trigger_10023() -> bool:
	var vstateId = DataManager.get_env_int("内政.灭亡势力")
	var vs = clVState.vstate(vstateId)
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var added = ske.affair_get_skill_val_int()
	if added >= 3:
		return false

	ske.affair_set_skill_val(added + 1)
	var msg = "{0}之败亡，自取之也\n分久必合，天意当归于吾\n（命令书永久 +1".format([
		vs.get_lord_name()
	])
	city.attach_free_dialog(msg, actorId)
	return false
