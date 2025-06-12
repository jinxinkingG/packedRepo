extends "effect_20000.gd"

#伏矢
#【伏矢】大战场，锁定技。你无视条件解锁计策[连弩]，你位于山地地形时，可使用该计策。

const STRATAGEM_NAME = "连弩"

func on_trigger_20004()->bool:
	var schemes = get_env_array("战争.计策列表")
	var msg = get_env_str("战争.计策提示")
	if schemes.empty():
		return false

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
