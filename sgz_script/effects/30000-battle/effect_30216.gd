extends "effect_30000.gd"

#解烦锁定技
#【解烦】小战场，锁定技，你的士兵对对方士兵造成伤害后，有40%概率对其造成重伤效果：该单位下回合造成伤害降为25%

const RATE = 40

func on_trigger_30023()->bool:
	var bu = ske.battle_is_unit_hit_by(UNIT_TYPE_SOLDIERS, UNIT_TYPE_SOLDIERS, ["ALL"])
	if bu == null:
		return false

	var hurtId = get_env_int("白兵伤害.单位")
	var hurt = get_battle_unit(hurtId)
	if hurt == null or hurt.disabled:
		return false

	if not Global.get_rate_result(RATE):
		return false
	hurt.set_severe_damaged()
	hurt.add_status_effect("重伤#FF0000")
	return false
