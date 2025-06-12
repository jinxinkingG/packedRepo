extends "effect_30000.gd"

#问卦士气效果
#【问卦】大战场，锁定技。你方武将对五行被其克制的敌将执行下列操作时，获得对应效果：1.用计，命中率+5%；2.攻击，当次白刃战士气+5。

func on_trigger_30005()->bool:
	var wa = DataManager.get_war_actor(ske.actorId)
	var targetWA = wa.get_battle_enemy_war_actor()
	if wa == null or targetWA == null:
		return false
	if not wa.five_phases_against(targetWA):
		return false
	ske.battle_change_morale(5, wa)
	ske.battle_report()
	return false
