extends "effect_20000.gd"

# 践行锁定技
#【践行】大战场，锁定技。你每获得100经验，增加1点机动力，同一回合内至多以此法增加10点机动力。

const MAX_AP = 10

func on_trigger_20013() -> bool:
	ske.set_war_skill_val([0, actor.get_exp()], 1)
	return false

func on_trigger_20043() -> bool:
	var setting = ske.get_war_skill_val_int_array()
	if setting.size() != 2:
		return false
	var ap = int((actor.get_exp() - setting[1]) / 100)
	ap = min(MAX_AP, ap)
	if ap <= setting[0]:
		return false
	ske.change_actor_ap(actorId, ap - setting[0])
	setting[0] = ap
	ske.set_war_skill_val(setting, 1)
	ske.war_report()
	return false
