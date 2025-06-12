extends "effect_20000.gd"

#骁袭效果实现
#【骁袭】大战场,锁定技。你方武将中存在拥有<马术>的武将时，你也获得<马术>；否则，你获得<先锋>

const HORSE_SKILL = "马术"
const PIONEER_SKILL = "先锋"

func appended_skill_list()->PoolStringArray:
	var ret = []
	if DataManager.get_current_scene_id() < 20000:
		return ret
	var me = DataManager.get_war_actor(actorId)
	if me == null or me.disabled:
		return ret
	for targetId in get_teammate_targets(me, 99999):
		# 这里必须 skip append，否则会死循环
		if SkillHelper.actor_has_skills(targetId, [HORSE_SKILL], true):
			ret.append(HORSE_SKILL)
			return ret
	ret.append(PIONEER_SKILL)
	return ret
