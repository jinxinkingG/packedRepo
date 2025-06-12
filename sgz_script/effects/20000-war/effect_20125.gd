extends "effect_20000.gd"

#知遇
#【知遇】大战场,锁定技。你方主将，若拥有<仁德>或<享乐>，其每回合额外恢复8点机动力。

func on_trigger_20013()->bool:
	var leader = DataManager.get_war_actor(me.get_main_actor_id())
	if leader == null or leader.disabled:
		return false

	if SkillHelper.actor_has_skills(leader.actorId, ["仁德", "享乐"]):
		ske.change_actor_ap(leader.actorId, 8)
		ske.war_report()
	return false
