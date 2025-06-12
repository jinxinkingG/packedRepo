extends "effect_20000.gd"

# 群英后续效果
#【群英】大战场，主将限定技。己方所有武将的武、知、统临时+8，持续到你方下个回合开始之前。

const ACTIVE_EFFECT_ID = 20600
const BUFF = 8

func on_trigger_20013() -> bool:
	var buffed = ske.get_war_skill_val_int_array(ACTIVE_EFFECT_ID)
	if buffed.empty():
		return false
	for targetId in buffed:
		ske.change_war_power(targetId, -BUFF)
		ske.change_war_wisdom(targetId, -BUFF)
		ske.change_war_leadership(targetId, -BUFF)
	ske.set_war_skill_val(0, 0, ACTIVE_EFFECT_ID)
	ske.war_report()
	return false

