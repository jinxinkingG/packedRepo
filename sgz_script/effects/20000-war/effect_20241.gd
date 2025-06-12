extends "effect_20000.gd"

#玲珑锁定效果
#【玲珑】大战场,锁定技。若你方没有诸葛亮，你视为拥有技能<火攻>；若你方有诸葛亮，其使用<八阵>消耗的机动力减半。

func appended_skill_list()->PoolStringArray:
	var ret = []
	if DataManager.get_current_scene_id() < 20000:
		return ret
	var me = DataManager.get_war_actor(actorId)
	if me == null or me.disabled:
		return ret
	var wa = DataManager.get_war_actor(StaticManager.ACTOR_ID_ZHUGELIANG)
	if not me.is_teammate(wa):
		ret.append("火攻")
	return ret
