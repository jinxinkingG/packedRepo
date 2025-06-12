extends "effect_30000.gd"

#神威技能实现
#【神威】小战场,锁定技。若你是小战场进攻方，你的战术值+X，对方战术值-X（X=你的等级）。

func on_trigger_30005():
	var x = actor.get_level()
	ske.battle_change_tactic_point(x)
	ske.battle_change_tactic_point(-x, me.get_battle_enemy_war_actor())
	ske.battle_report()
	return false
