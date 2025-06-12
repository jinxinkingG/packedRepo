extends "effect_20000.gd"

#扬尘
#【扬尘】大战场,锁定技。你无条件拥有计策[虚兵]，使用[虚兵]时，以“武”替代“知”计算命中率，若成功，则你的体力+8。

const HP_RECOVER = 8
const STRATAGEM_NAME = "虚兵"

func on_trigger_20009()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.name != STRATAGEM_NAME:
		return false
	if se.succeeded <= 0:
		return false
	var recovered = ske.change_actor_hp(me.actorId, HP_RECOVER)
	if recovered > 0:
		var msg = "{0}体力恢复至{1}".format([
			actor.get_name(), int(actor.get_hp())
		])
		se.append_result(ske.skill_name, msg, recovered, me.actorId)
	return false

func on_trigger_20017()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.name != STRATAGEM_NAME:
		return false
	var diff = actor.get_power() - actor.get_wisdom()
	if diff <= 0:
		return false
	change_scheme_chance(me.actorId, ske.skill_name, diff)
	return false

func on_trigger_20004()->bool:
	var schemes = get_env_array("战争.计策列表")
	var msg = get_env_str("战争.计策提示")

	var found = false
	var costRequired = true
	for scheme in schemes:
		if int(scheme[1]) == 0:
			costRequired = false
		if str(scheme[0]) == STRATAGEM_NAME:
			found = true
			break
	if not found:
		var cost = 0
		if costRequired:
			var schemeInfo = StaticManager.get_stratagem(STRATAGEM_NAME)
			cost = schemeInfo.get_cost_ap(me.actorId)
		schemes.append([STRATAGEM_NAME, cost, ""])
	change_stratagem_list(me.actorId, schemes)
	return false
