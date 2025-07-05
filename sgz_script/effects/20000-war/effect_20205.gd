extends "effect_20000.gd"

#王佐锁定技
#【王佐】大战场,锁定技。我方大战场回合结束时，我方所有武将机动力+3

const BUFF_AP = 3

func on_trigger_20016()->bool:
	var wv = me.war_vstate()
	if wv == null:
		return false
	for wa in wv.get_war_actors(false):
		ske.change_actor_ap(wa.actorId, BUFF_AP, false)
	ske.war_report()
	# 统一更新一次光环，避免重复更新耗时
	SkillHelper.update_all_skill_buff(ske.skill_name)
	return false
