extends "effect_20000.gd"

#连罪锁定效果 #施加状态
#【连罪】大战场，锁定技。若你是己方兵力最大的将领之一，你视为拥有<放逐>；否则，若你是己方兵力最少的将领之一，禁用你的其他技能。

const SKILL_NAME = "连罪"

func appended_skill_list()->PoolStringArray:
	var ret = []
	if DataManager.get_current_scene_id() < 20000:
		return ret
	var me = DataManager.get_war_actor(actorId)
	if me == null or me.disabled:
		return ret
	actor = me.actor()
	var wv = me.war_vstate()
	if wv == null:
		return ret
	var maxSoldiers = -1
	var minSoldiers = 9999
	for wa in wv.get_war_actors(false):
		var soldiers = wa.actor().get_soldiers()
		if soldiers > maxSoldiers:
			maxSoldiers = soldiers
		if soldiers < minSoldiers:
			minSoldiers = soldiers
	if actor.get_soldiers() >= maxSoldiers:
		SkillHelper.clear_ban_actor_skill(20000, [actorId], [], [actorId], SKILL_NAME)
		ret.append("放逐")
	elif actor.get_soldiers() <= minSoldiers:
		# 不但不追加技能，而且禁用现有技能
		for skillName in SkillHelper.get_actor_skill_names(actorId, 20000, true):
			if skillName != SKILL_NAME:
				SkillHelper.ban_actor_skill(20000, actorId, skillName, 99999, actorId, SKILL_NAME)
	return ret
