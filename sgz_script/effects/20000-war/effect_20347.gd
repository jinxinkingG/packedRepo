extends "effect_20000.gd"

#烈驹效果
#【烈驹】大战场，主将锁定技。你方所有武将，机动力上限+5

const EXTRA_AP_LIMIT = 5

func check_trigger_correct():
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled:
		return false
	if wa.dic_other_variable.has("烈驹"):
		return false
	wa.dic_other_variable["烈驹"] = 1
	if not wa.dic_other_variable.has("额外机上限"):
		wa.dic_other_variable["额外机上限"] = 0
	wa.dic_other_variable["额外机上限"] += EXTRA_AP_LIMIT
	return false
