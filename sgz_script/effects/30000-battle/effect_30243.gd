extends "effect_30000.gd"

#武略小战场效果
#【武略】小战场，锁定技。白刃战初始，若你本回合使用过计策，你的战术值+6

const WAR_EFFECT_ID = 20475

func on_trigger_30005()->bool:
	if ske.get_war_skill_val_int(WAR_EFFECT_ID) > 0:
		ske.battle_change_tactic_point(6)
	ske.battle_report()
	return false
