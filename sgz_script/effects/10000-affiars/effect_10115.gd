extends "effect_10000.gd"

# 通博效果
#【通博】内政&大战场，锁定技。你方装备库中每有一种书，你的知+1，政+2。

func on_trigger_10001() -> bool:
	var city = clCity.city(get_working_city_id())
	update_buff(city.get_vstate_id())
	return false

func on_trigger_10021() -> bool:
	var city = clCity.city(get_working_city_id())
	var vstateId = city.get_vstate_id()
	if vstateId < 0:
		return false
	update_buff(vstateId)
	return false

func update_buff(vstateId:int) -> void:
	var vs = clVState.vstate(vstateId)
	var books = {}
	for item in vs.get_stored_equipments():
		var equip = item[0]
		if equip.type != "道具" or equip.subtype() != "书":
			continue
		books[equip.id] = 1
	var buff = books.size()
	actor._set_attr("临知", buff)
	actor._set_attr("临政", buff * 2)
	return
