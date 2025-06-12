extends "effect_20000.gd"

#武略大战场效果
#【武略】小战场，锁定技。白刃战初始，若你本回合使用过计策，你的战术值+6

func on_trigger_20009()->bool:
	ske.set_war_skill_val(1, 1)
	return false
