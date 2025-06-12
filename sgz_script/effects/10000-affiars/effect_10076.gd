extends "effect_10000.gd"

#久随锁定技
#【久随】内政，锁定技，你的统视为+X，至多以此法增至90（X=你在本势力内的月数/12，离开该势力时清零）。

const EFFECT_ID = 10076
const EXTRA_KEY = "附统"

func get_ext_info()->String:
	var skv = SkillHelper.get_skill_variable(10000, EFFECT_ID, actorId)
	if skv["turn"] <= 0 or skv["value"] == null:
		return ""
	var following = Global.intarrval(skv["value"])
	if following.size() != 2:
		return ""
	var year = ""
	if following[1] > 12:
		year = "{0}年".format([int(following[1] / 12)])
	var lordId = following[0]
	return "已跟随[color=blue]{0}[/color]{1}{2}个月".format([
		ActorHelper.actor(lordId).get_name(), year, following[1] % 12
	])

func on_trigger_10001()->bool:
	ske.affair_cd(1)
	var cityId = get_working_city_id()
	if cityId < 0:
		return false
	var city = clCity.city(cityId)
	var lordId = city.get_lord_id()
	var following = ske.affair_get_skill_val_int_array()
	if following.size() != 2:
		following = [lordId, 1]
	elif following[0] != lordId:
		following = [lordId, 1]
	else:
		following[1] += 1
	ske.affair_set_skill_val(following)
	var extra = int(following[1] / 12)
	# 暂时不考虑与其他技能的叠加
	# FIXME later
	actor._set_attr(EXTRA_KEY, extra)
	return false
