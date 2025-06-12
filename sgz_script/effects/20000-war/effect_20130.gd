extends "effect_20000.gd"

#魂智
#【魂智】大战场,锁定技。你使用伤兵类计策命中后，你的兵力回复所有目标计策伤害的一定百分比（其中主要目标25%，其他目标10%）。兵力回复上限为2500。

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var targetId = get_env_int("计策.ONCE.伤害武将")
	var damage = get_env_int("计策.ONCE.伤害")
	if targetId < 0 or damage <= 0:
		return false
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(self.actorId) != self.actorId:
		return false
	if se.targetId < 0:
		return false
	var recover = int(damage * 0.25)
	if targetId != se.targetId:
		recover = int(damage * 0.1)

	var actor = ActorHelper.actor(self.actorId)
	recover = int(min(recover, 2500 - actor.get_soldiers()))
	if recover <= 0:
		return false

	actor.set_soldiers(actor.get_soldiers() + recover)
	se.append_result("伤兵量", ske.skill_name, -recover, self.actorId)
	return false
