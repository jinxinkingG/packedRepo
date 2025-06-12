extends "effect_30000.gd"

#严整效果实现
#【严整】小战场，锁定技。你的统临时+x/2，战术值+x，x为你剩余机动力，最大为12。

func on_trigger_30006() -> bool:
	var sbp = ske.get_battle_skill_property()
	var x = max(0, me.action_point)
	x = min(12, x)
	sbp.leader += int(x/2)
	sbp.tp += x
	ske.apply_battle_skill_property(sbp)
	ske.battle_report()
	return false
