extends "effect_30000.gd"

#统御发动，小战场buff
#【统御】小战场,锁定技。你的统临时+x，战术值+x/2，x＝你的等级。

func on_trigger_30006() -> bool:
	var sbp = ske.get_battle_skill_property()
	var x = actor.get_level()
	sbp.leader += x # 统+等级
	sbp.tp += int(x/2) # 战术+等级/2
	ske.apply_battle_skill_property(sbp)
	ske.battle_report()
	return false
