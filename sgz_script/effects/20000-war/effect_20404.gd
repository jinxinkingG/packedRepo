extends "effect_20000.gd"

#过论大战场效果
#【过论】内政&大战场,锁定技。1.内政:非12月,你整日醉酒不参与任何内政活动；12月，你方命令书不多于2枚时，你执行提升产业/土地/人口/防灾/赏赐/民忠，效果为4倍。2.大战场：战争前8日，你拥有<看破>；战争第9日开始，你拥有<急功>。

func appended_skill_list()->PoolStringArray:
	var ret = []
	if DataManager.get_current_scene_id() < 20000:
		return ret
	var wf = DataManager.get_current_war_fight()
	if wf.date <= 8:
		ret.append("看破")
	else:
		ret.append("急功")
	return ret
