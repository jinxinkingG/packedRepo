extends "effect_30000.gd"

#忠绝效果实现
#【忠绝】小战场,锁定技。你用0.5*(忠+体) 代替你的体计算你的伤害

func on_trigger_30014()->bool:
	var unit = get_action_unit()
	if unit == null or unit.leaderId != me.actorId:
		return false
	if unit.get_unit_type() != "将":
		return false

	var base = get_env_int("白兵.伤害基准体力")
	if base < 0:
		return false
	var hp = (unit.get_hp() + actor.get_loyalty()) * 0.5
	set_env("白兵.伤害基准体力", hp)
	return false
