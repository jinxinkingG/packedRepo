extends "effect_20000.gd"

#连谋锁定技
#【连谋】大战场，锁定技。你方的女性武将使用「需选定武将的技能」时，选定距离+3。

func on_trigger_20023()->bool:
	var target = DataManager.get_war_actor(ske.actorId)
	if target == null:
		return false
	if target.actor().get_gender() != "女":
		return false
	target.set_tmp_variable("技能附加距离", 3)
	return false
