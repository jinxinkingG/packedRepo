extends "effect_20000.gd"

#反思效果实现
#【反思】大战场,锁定技。你使用伤兵类计策失败的场合，你的经验+150，若你经验达到上限，机动力额外+2

const EXP_GAIN = 150

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(self.actorId) != self.actorId:
		return false
	if se.succeeded > 0:
		return false
	if not se.damage_soldier():
		return false

	var me = DataManager.get_war_actor(self.actorId)
	var added = ske.change_actor_exp(self.actorId, EXP_GAIN)
	# 自身发动伤兵计策失败
	if added < EXP_GAIN:
		if me != null:
			me.action_point += 2
	var msg = "反躬自省，经验+{0}".format([added])
	if me.get_controlNo() < 0:
		msg = me.get_name() + msg
	se.append_result(ske.skill_name, msg, added, self.actorId)
	return false
