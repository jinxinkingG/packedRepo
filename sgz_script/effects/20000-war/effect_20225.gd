extends "effect_20000.gd"

#游说
#【游说】大战场,锁定技。你的计策列表无视条件拥有<笼络>，若你知不小于85，<笼络>机动力默认消耗由10变为7

const STRATAGEM_NAME = "笼络"

func on_trigger_20004() -> bool:
	var schemes = DataManager.get_env_array("战争.计策列表")

	var found = false
	for scheme in schemes:
		if scheme[0] == STRATAGEM_NAME:
			found = true
			# 多个技能会冲突，再想想
			#scheme[2] = ske.skill_name
	if not found:
		schemes.append([STRATAGEM_NAME, 0, ske.skill_name])
	change_stratagem_list(actorId, schemes)
	return false

func on_trigger_20005() -> bool:
	if actor.get_wisdom() < 85:
		return false
	var settings = DataManager.get_env_dict("计策.消耗")
	var name = settings["计策"]
	var cost = int(settings["所需"])
	if name != STRATAGEM_NAME:
		return false
	reduce_scheme_ap_cost(name, 7)
	return false
