extends "effect_20000.gd"

# 徒倾效果
#【徒倾】大战场，锁定技。若你方没有可撤退其他的城市。每回合你的机动力额外增加X(X=你的等级)。

func on_trigger_20013() -> bool:
	var wv = me.war_vstate()
	if wv == null:
		return false
	if not wv.get_all_retreat_city_ids().empty():
		return false
	ske.change_actor_ap(actorId, actor.get_level())
	ske.war_report()
	return false
