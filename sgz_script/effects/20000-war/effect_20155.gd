extends "effect_20000.gd"

#寻机效果
#【寻机】大战场,锁定技。你的机动力上限+10，每回合恢复的机动力额外+2

func check_trigger_correct():
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.actorId
	var me = DataManager.get_war_actor(self.actorId)
	if me == null or me.disabled:
		return false
	me.action_point += 2
	if me.dic_other_variable.has("寻机"):
		return false
	me.dic_other_variable["寻机"] = 1
	if not me.dic_other_variable.has("额外机上限"):
		me.dic_other_variable["额外机上限"] = 0
	me.dic_other_variable["额外机上限"] += 10
	return false
