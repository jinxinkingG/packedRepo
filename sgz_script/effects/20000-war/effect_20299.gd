extends "effect_20000.gd"

#天命效果
#【天命】大战场，锁定技。你的点数必定为9，每日你的机动力回满，你被用计时，对方命中率减半

func on_trigger_20013()->bool:
	me.set_poker_point(9)
	me.action_point = max(me.get_max_action_ap(), me.action_point)
	return false

func on_trigger_20017()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.targetId != me.actorId:
		return false
	change_scheme_chance_rate(me.actorId, ske.skill_name, -50)
	return false
