extends "effect_20000.gd"

#敌逊效果
#【敌逊】大战场,锁定技。己方武将被用伤兵计时，在同1次计策中只有1名武将会受到伤害。

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var me = DataManager.get_war_actor(self.actorId)
	var se = DataManager.get_current_stratagem_execution()
	if se.actionId != ske.actorId:
		return false
	var damageTargetId = get_env_int("计策.ONCE.伤害武将")
	var damage = get_env_int("计策.ONCE.伤害")
	if damage <= 0:
		return false
	if damageTargetId == se.targetId:
		return false
	set_env("计策.ONCE.伤害", 0)
	var msg = "{0}发动【敌逊】\n仅{1}可受计策伤害".format([
		ActorHelper.actor(self.actorId).get_name(),
		ActorHelper.actor(se.targetId).get_name(),
	])
	# 修改汇报逻辑，只汇报一次整体效果
	se.append_result(ske.skill_name, msg, 0, self.actorId, true)
	return false
