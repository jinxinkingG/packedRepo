extends "effect_30000.gd"

#马钉技能实现
#【马钉】小战场,锁定技。整个小战场，所有骑兵单位，每移动一步，兵力-5。

func on_trigger_30007() -> bool:
	return after_move()

func on_trigger_30017() -> bool:
	return after_move()

func after_move() -> bool:
	var bu = get_action_unit()
	if bu == null or bu.disabled:
		return false

	if bu.get_unit_type() != "骑":
		return false
	if bu.last_action_name != "移动":
		return false
	bu.set_hp(bu.get_hp() - 5)
	return false
