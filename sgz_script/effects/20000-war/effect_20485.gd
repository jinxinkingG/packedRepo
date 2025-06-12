extends "effect_20000.gd"

#忿肆锁定效果
#【忿肆】大战场，锁定技。你攻击敌将/被敌将攻击时，发起方需额外支付4点体力作为条件（不足则无法攻击）。

const HP_COST = 4

func on_trigger_20015()->bool:
	var bf = DataManager.get_current_battle_fight()
	ske.change_actor_hp(bf.get_attacker_id(), -HP_COST)
	ske.war_report()
	return false
