extends "effect_20000.gd"

#得堑锁定效果
#【得堑】大战场，锁定技。你被使用伤兵类计策时，你的经验+被伤害兵力的50%。

func on_trigger_20012()->bool:
	if me == null or me.disabled:
		return false

	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	if se.succeeded <= 0:
		return false

	var damage = se.get_soldier_damage_for(actorId)
	if damage <= 0:
		return false

	var learned = int(damage / 2)
	learned = ske.change_actor_exp(actorId, learned)
	ske.war_report()
	if learned > 0:
		var msg = "吃一堑，长一智！\n（【{0}】获得经验 {1}".format([
			ske.skill_name, learned,
		])
		me.attach_free_dialog(msg, 2)
	return false
