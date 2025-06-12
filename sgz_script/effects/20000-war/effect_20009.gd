extends "effect_20000.gd"

#启异锁定效果实现
#【启异】大战场，锁定技。战争结束时，你可以保留一半数量的[卷]存留到下次战争。若你方存在1名以上的武将同时拥有某个技能，每有1个相同的技能，你的卷标记上限+3。

const EFFECT_ID = 20009
const FLAG_NAME = "卷"
const MANJUAN_EFFECT_ID = 20008
const FLAG_NAME_LIMIT = "异"

func on_trigger_20013():
	if me == null or me.disabled:
		return false
	if wf.date == 1:
		var kept = SkillHelper.get_skill_flags_number(10000, EFFECT_ID, actorId, FLAG_NAME)
		if kept > 0:
			SkillHelper.set_skill_flags(20000, MANJUAN_EFFECT_ID, actorId, FLAG_NAME, kept)
	var skillCounters = {}
	var dup = 0
	var wv = me.war_vstate()
	if wv == null:
		return false
	for wa in wv.get_war_actors(false):
		for skill in SkillHelper.get_actor_skill_names(wa.actorId):
			if not skillCounters.has(skill):
				skillCounters[skill] = 0
			skillCounters[skill] += 1
			if skillCounters[skill] == 2:
				dup += 1
	SkillHelper.set_skill_flags(20000, EFFECT_ID, actorId, FLAG_NAME_LIMIT, 20 + dup * 3)
	return false
