extends "effect_10000.gd"

#文姬效果
#【文姬】内政,锁定技。你初次出仕为<阳>面，若你过月时为流放状态，你永久转为<阴>面；同时，你在“绿色黑边”势力时，转为<阳>面。

const EFFECT_ID = 10027
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000_delta(delta:float):
	Global.wait_for_confirmation(FLOW_BASE + "_end", "", delta)
	return

func effect_10027_AI_start():
	goto_step("start")
	return

func effect_10027_start():
	SoundManager.play_anim_bgm("res://resource/sounds/bgm/GameDead_End.ogg")
	var msg = "胡笳十八拍\n也难掩蒲草的悲歌……\n（{0}转为<阴>".format([
		actor.get_name()
	])
	SceneManager.show_confirm_dialog(msg, actorId, 3)
	LoadControl.set_view_model(2000)
	return

func effect_10027_end():
	DataManager.twinkle_citys = []
	LoadControl.end_script()
	return

func on_trigger_10001()->bool:
	return _check_status()

func on_trigger_10009()->bool:
	return self._check_status()

func _check_status()->bool:
	if actor.has_side() and actor.is_status_officed() and not actor.is_face_positive():
		# 检查是否有机会转阳
		var cityId = get_working_city_id()
		if cityId < 0:
			return false
		var city = clCity.city(cityId)
		if city.get_vstate_id() == StaticManager.VSTATEID_CAOCAO:
			actor.set_face(true)
		return false

	if actor.is_face_positive() and actor.is_status_exiled():
		actor.set_face(false)
		return true
	return false
