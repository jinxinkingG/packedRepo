extends "effect_20000.gd"

#游说
#【游说】大战场,锁定技。你的计策列表无视条件拥有<笼络>，若你知不小于85，<笼络>机动力默认消耗由10变为7

const EFFECT_ID = 20225
const STRATAGEM_NAME = "笼络"

func check_trigger_correct()->bool:
	match self.triggerId:
		20004:
			_on_scheme_menu()
		20005:
			_on_scheme_cost()
	return false

func _on_scheme_menu()->void:
	var actor = ActorHelper.actor(self.actorId)
	if not check_env(["战争.计策列表", "战争.计策提示"]):
		return
	var schemes = Array(get_env("战争.计策列表"))
	var msg = str(get_env("战争.计策提示"))

	var found = false
	var costRequired = true
	for scheme in schemes:
		if int(scheme[1]) == 0:
			costRequired = false
		if str(scheme[0]) == STRATAGEM_NAME:
			if costRequired and actor.get_wisdom() >= 85:
				scheme[1] = max(1, int(scheme[1]) - 3)
			found = true
			break
	inc_skill_triggered_times(self.actorId, EFFECT_ID, 99999)
	if not found:
		var cost = 0
		if costRequired:
			var schemeInfo = StaticManager.get_stratagem(STRATAGEM_NAME)
			cost = schemeInfo.get_cost_ap(self.actorId)
			if actor.get_wisdom() >= 85:
				cost = max(1, cost - 3)
		schemes.append([STRATAGEM_NAME, cost, ""])
		clear_skill_triggered_times(self.actorId, EFFECT_ID)
	change_stratagem_list(self.actorId, schemes)
	return

func _on_scheme_cost()->void:
	if get_skill_triggered_times(self.actorId, EFFECT_ID) <= 0:
		return
	var cost = get_env_int("计策.消耗.所需")
	if cost <= 7:
		return
	set_scheme_ap_cost(STRATAGEM_NAME, 7)
	return
