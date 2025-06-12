extends "effect_20000.gd"

#博通锁定技 #技能附加
#【博通】大战场，锁定技。若你“知”大于“武”，你附加<水攻>；否则你附加<恃武>。若你“政”大于“统”，你附加<游说>；否则你附加<统御>

func appended_skill_list() -> PoolStringArray:
	var ret = []
	if DataManager.get_current_scene_id() < 20000:
		return ret
	var me = DataManager.get_war_actor(self.actorId)
	if me == null or me.disabled:
		return ret
	var actor = ActorHelper.actor(actorId)
	if actor.get_wisdom() > actor.get_power():
		ret.append("水攻")
	else:
		ret.append("恃武")
	if actor.get_politics() > actor.get_leadership():
		ret.append("游说")
	else:
		ret.append("统御")
	return ret
