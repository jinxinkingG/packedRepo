extends "effect_20000.gd"

#问卦计策效果
#【问卦】大战场，锁定技。你方武将对五行被其克制的敌将执行下列操作时，获得对应效果：1.用计，命中率+5%；2.攻击，当次白刃战士气+5。

func on_trigger_20017()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(actorId) != ske.actorId:
		return false
	if se.targetId < 0:
		return false
	var wa = DataManager.get_war_actor(ske.actorId)
	var targetWA = DataManager.get_war_actor(se.targetId)
	if wa == null or targetWA == null:
		return false
	if not wa.five_phases_against(targetWA):
		return false
	change_scheme_chance(actorId, ske.skill_name, 5)
	return false
