extends "effect_20000.gd"

#天运效果
#【天运】大战场，锁定技。你和你方主将点数必定为9。若你方君主德＜50，你无法主动移动，你方主将每日机动力回满；若你方君主德≥50，你无法主动使用计策，你方主将被用计时，对方命中率减半

func on_trigger_20013()->bool:
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled:
		return false
	if ske.actorId == actorId:
		me.set_poker_point(9)
		if ActorHelper.actor(me.get_lord_id()).get_moral() < 50:
			me.dic_other_variable["禁止移动"] = 1
	if ske.actorId == me.get_main_actor_id():
		wa.set_poker_point(9)
		wa.action_point = max(wa.get_max_action_ap(), wa.action_point)
	return false

func on_trigger_20017()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.targetId != me.get_main_actor_id():
		return false
	change_scheme_chance_rate(actorId, ske.skill_name, -50)
	return false

func on_trigger_20024()->bool:
	var key = "战争.计策.允许.{0}".format([actorId])
	if DataManager.get_env_int(key) != 1:
		return false
	if ActorHelper.actor(me.get_lord_id()).get_moral() >= 50:
		var msg = "因【{0}】效果\n不可发动计策".format([ske.skill_name])
		DataManager.set_env(key, msg)
	return false
