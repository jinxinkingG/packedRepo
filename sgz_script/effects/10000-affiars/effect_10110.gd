extends "effect_10000.gd"

#英据锁定技
#【英据】内政，君主锁定技。开局三年内，势力城池进行运输和武将移动时视为互相联通。三年后，你视为拥有<邀虎>。

const EFFECT_ID = 10110
const EXTRA_SKILLS = [
	["木牛", "流马"],
	["邀虎"],
]

func get_ext_info()->String:
	var leading = SkillHelper.get_skill_variable_int_array(10000, EFFECT_ID, actorId)
	if leading.size() != 2:
		return ""
	if leading[0] < 0 or leading[1] <= 0:
		return ""
	var year = ""
	if leading[1] > 12:
		year = "{0}年".format([int(leading[1] / 12)])
	var vstateId = leading[0]
	return "已为君主[color=blue]{0}{1}个月[/color]".format([
		year, leading[1] % 12
	])

func on_trigger_10001()->bool:
	for skills in EXTRA_SKILLS:
		for skill in skills:
			ske.affair_remove_skill(actorId, skill)
	var cityId = get_working_city_id()
	if cityId < 0:
		return false
	var city = clCity.city(cityId)
	var vstateId = city.get_vstate_id()
	var lordId = city.get_lord_id()
	var leading = ske.affair_get_skill_val_int_array()
	if leading.size() != 2:
		leading = [-1, 0]
	if lordId == actorId:
		if leading[0] != vstateId:
			leading = [vstateId, 1]
		else:
			leading[1] += 1
	else:
		leading = [-1, 0]
	ske.affair_set_skill_val(leading)
	if leading[0] < 0:
		return false
	var addIdx = 0
	var removeIdx = 1
	if leading[1] > 36:
		addIdx = 1
		removeIdx = 0
	for skill in EXTRA_SKILLS[addIdx]:
		ske.affair_add_skill(actorId, skill, 99999)
	return false
