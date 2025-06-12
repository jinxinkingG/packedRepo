extends "effect_20000.gd"

#冷静效果实现
#【冷静】大战场,锁定技。你使用计策时，命中率+x%；你被用计时，对方命中率-x%，x＝你的等级。

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var actor = ActorHelper.actor(self.actorId)
	var se = DataManager.get_current_stratagem_execution()
	var x = actor.get_level()
	if se.get_action_id(self.actorId) == self.actorId:
		change_scheme_chance(self.actorId, ske.skill_name, x)
	elif se.targetId == self.actorId:
		change_scheme_chance(self.actorId, ske.skill_name, -x)
	return false
