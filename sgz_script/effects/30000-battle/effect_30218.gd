extends "effect_30000.gd"

#协战锁定技
#【协战】小战场，锁定技。你方士兵每攻击对方武将一次，你的体力+2。

const HP_RECOVER = 1

func on_trigger_30023()->bool:
	var bu = ske.battle_is_unit_hit_by(UNIT_TYPE_SOLDIERS, ["将"], ["ALL"])
	if bu == null:
		return false

	var unit = me.battle_actor_unit()
	if unit == null:
		return false
	ske.battle_change_unit_hp(unit, HP_RECOVER)
	return false
