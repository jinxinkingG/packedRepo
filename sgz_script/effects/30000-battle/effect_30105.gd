extends "effect_30000.gd"

#拦拿效果
#【拦拿】小战场,锁定技。你持枪时，你的格挡几率额外+10%

const BUFF = {
	"格挡率": 10,
	"BUFF": 1,
}

func on_trigger_30005() -> bool:
	var bu = me.battle_actor_unit()
	if bu == null or bu.disabled:
		return false
	if "枪" in bu.get_unit_equip():
		ske.battle_buff_unit(bu, BUFF)
	return false
