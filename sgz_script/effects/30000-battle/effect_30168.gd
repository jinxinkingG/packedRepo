extends "effect_30000.gd"

#残勇锁定技
#【残勇】小战场，锁定技。你的体力＜50时，你的格挡率+10%

const BUFF = {
	"格挡率": 10,
	"BUFF": 1,
}

func on_trigger_30009():
	var unit = me.battle_actor_unit()
	if unit == null or unit.disabled:
		return false
	var buff = BUFF
	if unit.get_hp() >= 50:
		buff = {}
	ske.battle_buff_unit(unit, buff)
	return false
