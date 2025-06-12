extends "effect_20000.gd"

#鲠毒效果
#【鲠毒】大战场，锁定技。你方武将中存在拥有<前非>的武将时，你附加<暴名>;否则，你附加<侠名>。

func appended_skill_list()->PoolStringArray:
	var ret = []
	if DataManager.get_current_scene_id() < 20000:
		return ret
	var me = DataManager.get_war_actor(self.actorId)
	if me == null or me.disabled:
		return ret
	for targetId in get_teammate_targets(me, 99999):
		# 这里必须 skip append，否则会死循环
		if SkillHelper.actor_has_skills(targetId, ["前非"], true):
			ret.append("暴名")
			return ret
	ret.append("侠名")
	return ret
