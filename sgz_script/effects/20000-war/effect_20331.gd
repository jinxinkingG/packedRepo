extends "effect_20000.gd"

#洞察大战场效果 #解除状态
#【洞察】大战场，锁定技。自身免疫负面状态，你和你附近 X 格内的队友受到计策伤害时，有概率伤害减半。（X = 等级/4，概率 = 智力 / 150）

func on_trigger_20022()->bool:
	var key1 = "BUFF.{0}".format([me.actorId])
	var key2 = "BUFF.DEC.{0}".format([me.actorId])
	var buff = get_env_str(key1)
	var flag = get_env_int(key2)
	if flag == 1:
		return false
	var status = me.get_buff(buff)
	if status["回合数"] <= 0:
		return false
	var buffInfo = StaticManager.get_buff(buff)
	if buffInfo.get_scene() != "大战场":
		return false
	if not buffInfo.is_negative():
		return false
	ske.remove_war_buff(ske.skill_actorId, buff)
	ske.war_report()
	var msg = "镇之以静，岿然不动\n（【{0}】免疫[{1}]".format([
		ske.skill_name, buff,
	])
	append_free_dialog(me, msg, 2)
	return false

func on_trigger_20011()->bool:
	var targetId = get_env_int("计策.ONCE.伤害武将")
	var targetWA = me
	if targetId != me.actorId:
		targetWA = DataManager.get_war_actor(targetId)
		var x = int(actor.get_level() / 4)
		if Global.get_range_distance(targetWA.position, me.position) > x:
			return false
	if not Global.get_rate_result(actor.get_wisdom() * 100 / 150):
		return false
	change_scheme_damage_rate(-50)
	return false
