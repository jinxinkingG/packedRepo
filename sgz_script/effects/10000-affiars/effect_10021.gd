extends "effect_10000.gd"

#误信/始终效果
#【误信】内政,转换技·锁定。你视为拥有技能<荐才>。若你当前所在势力不是“初次出仕的势力”（@初势力），且该势力未灭亡，则你永久转为<阴>，且知武互换。
#【始终】内政,转换技·锁定。①内政：每月你的经验+250。若你符合以下情况之一，转为<阳>，且知武互换。1.你当前所在势力是“初次出仕的势力”（@初势力）；2.（@初势力）灭亡。②大战场：你拥有<散谣>。

# 误信和始终的判断条件与效果是一致的
func on_trigger_10001()->bool:
	var cityId = get_working_city_id()
	if cityId < 0:
		return false

	ske.affair_cd(1)
	var city = clCity.city(cityId)
	var vstateId = city.get_vstate_id()
	actor.set_initial_vstate_id(vstateId)
	var prev = actor.get_side(true)
	if prev == "阴":
		actor.add_exp(250)

	var originalVstateId = actor.get_initial_vstate_id()
	if originalVstateId == vstateId:
		actor.set_face(true)
	elif clVState.vstate(originalVstateId).is_perished():
		actor.set_face(true)
	else:
		actor.set_face(false)
	var current = actor.get_side(true)
	if current != prev:
		# 发生了翻转，知武互换
		var wisdom = actor._get_attr_int_original("知")
		var power = actor._get_attr_int_original("武")
		actor._set_attr_int("知", power)
		actor._set_attr_int("武", wisdom)

	return false
