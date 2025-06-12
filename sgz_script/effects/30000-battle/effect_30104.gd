extends "effect_30000.gd"

#疾护效果
#【疾护】小战场,锁定技。你的格挡几率额外+5%

const BUFF = {
	"格挡率": 5,
	"BUFF": 1,
}

func on_trigger_30005() -> bool:
	var bu = me.battle_actor_unit()
	if bu == null or bu.disabled:
		return false
	ske.battle_buff_unit(bu, BUFF)
	return false
