extends "effect_30000.gd"

# 愈伤效果
#【愈伤】小战场，锁定技。你体＜50时，小战场每过1轮，你的体力+2

const HP_RECOVER = 2

func on_trigger_30009() -> bool:
	if actor.get_hp() >= 50:
		return false
	var unit = me.battle_actor_unit()
	if unit == null:
		return false
	ske.battle_change_unit_hp(unit, HP_RECOVER)
	unit.add_status_effect("愈伤 +{0}#00FF00".format([HP_RECOVER]))
	ske.battle_report()
	return false
