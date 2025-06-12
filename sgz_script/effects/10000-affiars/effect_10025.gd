extends "effect_10000.gd"

#备战主动技
#【备战】内政,锁定技。每月你的永久标记[备]+100。你可以通过发动此技能将[备]转为等量的金。

const EFFECT_ID = 10025
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const FLAG_NAME = "备"

func effect_10025_start()->void:
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.actorId
	var actor = ActorHelper.actor(self.actorId)
	var x = SkillHelper.get_skill_flags_number(10000, EFFECT_ID, self.actorId, FLAG_NAME)
	if x <= 0:
		var msg = "战备不足..."
		play_dialog(actorId, msg, 3, 2000)
		return

	var cityId = self.get_working_city_id()
	var city = clCity.city(cityId)
	var goldToGo = 9999 - city.get_gold()
	goldToGo = min(goldToGo, x)
	if goldToGo <= 0:
		var msg = "此城金已充足"
		play_dialog(actorId, msg, 1, 2000)
		return

	x = x - goldToGo
	SkillHelper.set_skill_flags(10000, EFFECT_ID, self.actorId, FLAG_NAME, x)
	city.add_city_property("金", goldToGo)
	var msg = "有备无患\n{0}的金增加了 {1}".format([
		city.get_name(), goldToGo
	])
	play_dialog(actorId, msg, 1, 2000)
	return

func on_view_model_2000()->void:
	SceneManager.show_cityInfo(true)
	wait_for_skill_result_confirmation()
	return
