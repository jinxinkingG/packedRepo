extends "effect_20000.gd"

#文武效果
#【文武】大战场,锁定技。若你是己方“武”最高的武将，你获得<勇突>；若你是己方“知”最高的武将，你获得<看破>。

func appended_skill_list() -> PoolStringArray:
	var ret = []
	if DataManager.get_current_scene_id() < 20000:
		return ret
	var me = DataManager.get_war_actor(actorId)
	if me == null or me.disabled:
		return ret
	var actor = ActorHelper.actor(actorId)
	var maxInt = actor.get_wisdom()
	var maxPower = actor.get_power()

	var wv = me.war_vstate()
	if wv == null:
		return ret
	for wa in wv.get_war_actors(false):
		maxInt = max(maxInt, wa.actor().get_wisdom())
		maxPower = max(maxPower, wa.actor().get_power())
	if maxInt == actor.get_wisdom():
		ret.append("看破")
	if maxPower == actor.get_power():
		ret.append("勇突")
	return ret
