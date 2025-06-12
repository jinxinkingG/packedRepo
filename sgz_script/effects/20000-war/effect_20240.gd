extends "effect_20000.gd"

#恃恐附加技能
#【恃恐】大战场,锁定技。你有知≥98的队友时，你视为拥有<挑衅>；否则，你视为拥有<恃体>。

func appended_skill_list()->PoolStringArray:
	var ret = []
	if DataManager.get_current_scene_id() < 20000:
		return ret
	var me = DataManager.get_war_actor(self.actorId)
	if me == null or me.disabled:
		return ret
	for targetId in get_teammate_targets(me, 9999):
		if ActorHelper.actor(targetId).get_wisdom() >= 98:
			ret.append("挑衅")
			break
	if ret.empty():
		ret.append("恃体")
	return ret
