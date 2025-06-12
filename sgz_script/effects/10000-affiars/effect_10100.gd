extends "effect_10000.gd"

#残烛锁定技
#【残烛】内政，君主锁定技。以你成为君主后计时：若小于1年，你视为拥有<明政>；否则，你视为拥有<暴威><色胆>。

const EFFECT_ID = 10100
const EXTRA_SKILLS = [
	["明政"],
	["暴威", "色胆"],
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
	ske.affair_cd(1)
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
	ske.affair_set_skill_val(leading)
	if leading[0] < 0:
		return false
	var addIdx = 0
	var removeIdx = 1
	if leading[1] > 12:
		addIdx = 1
		removeIdx = 0
	for skill in EXTRA_SKILLS[addIdx]:
		ske.affair_add_skill(actorId, skill, 99999)
	for skill in EXTRA_SKILLS[removeIdx]:
		ske.affair_remove_skill(actorId, skill)
	return false
