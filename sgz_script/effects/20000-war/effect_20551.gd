extends "effect_20000.gd"

#仇异锁定技
#【仇异】大战场，锁定技。你对女性角色使用伤兵计时，以「100-德」替代「知」计算命中率。

func on_trigger_20017() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	var target = ActorHelper.actor(se.targetId)
	if target.get_gender() != "女":
		return false
	var x = 100 - actor.get_moral() - actor.get_wisdom()
	change_scheme_chance(actorId, ske.skill_name, x)
	return false
