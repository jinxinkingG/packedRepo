extends "effect_30000.gd"

#力沛锁定技
#【力沛】小战场，锁定技。你体力＞40时，武临时+8（被打到体小等于40后，效果消失。）

const POWER_BUFF = 8

func on_trigger_30009()->bool:
	var buffed = ske.get_battle_skill_val_int() > 0
	if actor.get_hp() > 40.0:
		if not buffed:
			ske.battle_change_power(POWER_BUFF)
			ske.set_battle_skill_val(1, 99999)
	else:
		if buffed:
			ske.battle_change_power(-POWER_BUFF)
			ske.set_battle_skill_val(0, 0)
	ske.battle_report()
	return false
