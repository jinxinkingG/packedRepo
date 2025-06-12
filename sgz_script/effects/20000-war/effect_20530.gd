extends "effect_20000.gd"

#强体锁定效果
#【强体】大战场，锁定技。①你的体力上限+X，X＝你的等级+2。②战争初始，若你体力不满，则你的体力回复至上限。

func on_trigger_20013() -> bool:
	var x = me.actor().get_level() + 2
	var current = ske.get_war_skill_val_int()
	if x > current:
		ske.set_war_skill_val(x)
		ske.change_actor_max_hp(actorId, x - current)
	var wf = DataManager.get_current_war_fight()
	if wf.date == 1:
		var diff = actor.get_max_hp() - actor.get_hp()
		if diff > 0:
			ske.change_actor_hp(actorId, diff)
	ske.war_report()
	return false
