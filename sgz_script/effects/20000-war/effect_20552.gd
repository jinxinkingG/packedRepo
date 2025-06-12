extends "effect_20000.gd"

#恃随锁定技
#【恃随】大战场，锁定技。你有知≥98的队友时，你视为拥有<知杰>；否则，你视为拥有<散谣>。

func appended_skill_list() -> PoolStringArray:
	var ret = []
	if DataManager.get_current_scene_id() < 20000:
		return ret
	me = DataManager.get_war_actor(actorId)
	if me == null or me.disabled:
		return ret
	var wv = me.war_vstate()
	if wv == null:
		return ret
	for wa in wv.get_war_actors(false):
		if wa.actor().get_wisdom() >= 98:
			ret.append("知杰")
			return ret
	ret.append("散谣")
	return ret
