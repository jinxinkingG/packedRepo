extends "effect_30000.gd"

#箭令效果
#【箭令】小战场，锁定技。每回合你第一次用弓箭射中对方士兵时，你的战术值+1

func on_trigger_30021()->bool:
	var bu = ske.battle_is_unit_hit_by(["将"], ["SOLDIERS"], ["射箭"])
	if bu == null:
		return false
	ske.battle_cd(1)
	me.battle_tactic_point += 1
	bu.add_status_effect("战术 +1")
	bu.add_status_effect("箭令#FF0000")
	return false
