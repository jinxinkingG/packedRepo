extends "effect_20000.gd"

#水攻
#【水攻】大战场，锁定技。你使用“乱水”所需机动力-1，命中率+5%，且拥有群伤效果

const REPLACEMENT = "乱水"
const REPLACED = "乱水*"

func check_trigger_correct()->bool:
	if not check_env(["战争.计策列表", "战争.计策提示"]):
		return false
	var schemes = Array(get_env("战争.计策列表"))
	var msg = str(get_env("战争.计策提示"))
	var replaced = get_env("战争.计策替换")
	if typeof(replaced) != TYPE_DICTIONARY:
		replaced = {}

	var costRequired = true
	for scheme in schemes:
		if costRequired and int(scheme[1]) == 0:
			costRequired = false
		var name = str(scheme[0])
		if name != REPLACEMENT:
			continue
		var cost = 0
		name = REPLACED
		if costRequired:
			var schemeInfo = StaticManager.get_stratagem(name)
			cost = schemeInfo.get_cost_ap(self.actorId)
		scheme[0] = name
		scheme[1] = cost
		replaced[REPLACEMENT] = REPLACED
	change_stratagem_list(self.actorId, schemes)
	set_env("战争.计策替换", replaced)
	return false
