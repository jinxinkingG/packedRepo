extends "effect_20000.gd"

#智复
#【智复】大战场,锁定技。你使用伤兵类计策成功时，你的机动力+1

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(self.actorId) != self.actorId:
		return false
	if se.succeeded <= 0:
		return false
	if not se.damage_soldier():
		return false

	var me = DataManager.get_war_actor(self.actorId)
	me.action_point += 1
	SceneManager.current_scene().war_map.update_ap()
	var msg = "因【{0}】回复1机动力".format([ske.skill_name])
	if me.get_controlNo() < 0:
		msg = me.get_name() + msg
	se.append_result(ske.skill_name, msg, 1, self.actorId)
	return false
