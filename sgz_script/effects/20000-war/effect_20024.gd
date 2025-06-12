extends "effect_20000.gd"

#藤甲大战场效果实现：处于非水地形时，你受到的火属性计策伤害+25%
#【藤甲】大战场&小战场,锁定技。你乘坐大象，默认8步2弓，且步兵站骑兵位，布阵后可以选择是否武将前置。非水战，你的步兵和弓兵只承受50%的伤害；大战场，处于非水地形时，火属性计策会对你造成125%的伤害

func on_trigger_20002()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.get_nature() != "火":
		return false
	change_scheme_damage_rate(25)
	return false
