extends "effect_20000.gd"

# 密推主动技 #解禁计策
#【密推】大战场，限定技。消耗20体力发动。己方所有武将的被禁用的计策均解禁，回合结束时，那些计策重新禁用。

const ACTIVE_EFFECT_ID = 20670

func on_trigger_20016() -> bool:
	var recovered = ske.get_war_skill_val_array(ACTIVE_EFFECT_ID)
	if recovered.empty():
		return false

	for r in recovered:
		var targetId = int(r[0])
		var schemeName = str(r[1])
		var cd = int(r[2])
		ske.disable_scheme(targetId, schemeName, cd)
	ske.war_report()
	return false
