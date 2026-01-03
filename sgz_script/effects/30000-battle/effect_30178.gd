extends "effect_30000.gd"

#游龙锁定效果
#【游龙】小战场，锁定技。你使用枪类武器时，可以额外攻击斜角。

func on_trigger_30024() -> bool:
	var unitId = DataManager.get_env_int("白兵.初始化单位ID")
	var bu = get_battle_unit(unitId)
	if bu == null:
		return false
	if bu.get_unit_type() != "将":
		return false

	var types = bu.get_unit_equip()
	if not "枪" in types:
		return false
	if "锤" in types:
		return false
	types.append("锤")
	bu.dic_combat["武器特性"] = types
	return false
