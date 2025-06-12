extends "effect_20000.gd"

#据守
#【据守】大战场，主将锁定技。若你为战争守方，你视为拥有<坚守>和<溃围>。

func appended_skill_list()->PoolStringArray:
	var ret = []
	if DataManager.get_current_scene_id() < 20000:
		return ret
	var me = DataManager.get_war_actor(self.actorId)
	if me == null or me.disabled:
		return ret
	if me.side() == "防守方" and me.get_main_actor_id() == self.actorId:
		ret.append("坚守")
		ret.append("溃围")
	return ret
