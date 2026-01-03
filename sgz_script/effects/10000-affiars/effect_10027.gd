extends "effect_10000.gd"

#文姬效果
#【文姬】内政,锁定技。初次出仕为<阳>面。若你被流放，立刻转为<阴>面；出仕于@势力#2势力时，转为<阳>面。

func on_trigger_10001() -> bool:
	_check_status()
	return false

func on_trigger_10009() -> bool:
	_check_status()
	return false

func _check_status() -> void:
	if not actor.has_side():
		return

	if actor.is_status_officed() and not actor.is_face_positive():
		# 检查是否有机会转阳
		var cityId = get_working_city_id()
		if cityId < 0:
			return
		var city = clCity.city(cityId)
		if city.get_vstate_id() == StaticManager.VSTATEID_CAOCAO:
			actor.set_face(true)
		return

	if actor.is_face_positive() and not actor.is_status_officed():
		actor.set_face(false)
		var cityId = actor.get_exiled_city_id()
		var city = clCity.city(cityId)
		if cityId < 0:
			city = clCity.city(cityId)
		actor.set_face(false)
		var msg = "胡笳十八拍\n也难掩蒲草的悲歌……\n（身世流离，转为 <阴> 面".format([
			actor.get_name()
		])
		city.attach_free_dialog(
			msg, actorId, 3,
			[cityId], 1, "res://resource/sounds/bgm/GameDead_End.ogg"
		)
	return
