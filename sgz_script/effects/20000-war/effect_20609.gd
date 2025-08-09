extends "effect_20000.gd"

# 识度效果
#【识度】大战场，锁定技。若你方没有其他拥有<看破>的武将，你视为拥有<看破>，否则你视为拥有<将计>。

const KANPO_SKILL = "看破"
const JIUJI_SKILL = "将计"

func appended_skill_list()->PoolStringArray:
	var ret = []
	if DataManager.get_current_scene_id() < 20000:
		return ret
	me = DataManager.get_war_actor(actorId)
	if me == null or me.disabled:
		return ret
	for targetId in get_teammate_targets(me, 99999):
		# 这里必须 skip append，否则会死循环
		if SkillHelper.actor_has_skills(targetId, [KANPO_SKILL], true):
			ret.append(JIUJI_SKILL)
			return ret
	ret.append(KANPO_SKILL)
	return ret
