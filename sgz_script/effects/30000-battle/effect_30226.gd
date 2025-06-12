extends "effect_30000.gd"

#迫阵锁定技 #布阵 #武将强化
#【迫阵】大战场，主将锁定技。你之外的你方“武系武将”在白刃战布阵后，武临时+5，且必定列阵在前。

func on_trigger_30005()->bool:
	if ske.actorId == actorId:
		return false
	var wa = DataManager.get_war_actor(ske.actorId)
	# 要求武系
	var power = wa.actor().get_power()
	if wa.actor().get_wisdom() > power:
		return false
	if wa.actor().get_leadership() > power:
		return false
	if wa.actor().get_politics() > power:
		return false
	ske.battle_change_power(5, wa)
	var bu = get_leader_unit(wa.actorId)
	if bu == null:
		return false
	ske.battle_unit_jump_forward(5, bu)
	ske.battle_report()
	return false
