extends "effect_20000.gd"

#智计
#【智计】大战场,锁定技。你使用计策每成功一次，你的[智]标记+1，上限x个，你的计策命中率+[智]标记数%，x=（你的等级*2-1）

const FLAG_NAME = "智"
const EFFECT_ID = 20127

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	match self.triggerId:
		20017: # 计策命中率判断
			var x = SkillHelper.get_skill_flags_number(20000, EFFECT_ID, self.actorId, FLAG_NAME)
			if x <= 0:
				return false
			change_scheme_chance(self.actorId, ske.skill_name, x)
		20004: # 计策菜单
			var x = SkillHelper.get_skill_flags_number(20000, EFFECT_ID, self.actorId, FLAG_NAME)
			if not check_env(["战争.计策列表", "战争.计策提示"]):
				return false
			var schemes = Array(get_env("战争.计策列表"))
			var msg = str(get_env("战争.计策提示"))
			var msgs = Array(msg.split("\n"))
			msgs.append("（[智计]: {0}".format([x]))
			msg = "\n".join(msgs.slice(0, 2))
			change_stratagem_list(self.actorId, schemes, msg)
		20012: # 计策结束后
			var se = DataManager.get_current_stratagem_execution()
			if se.succeeded <= 0:
				return false
			if se.get_action_id(self.actorId) != self.actorId:
				return false
			var actor = ActorHelper.actor(self.actorId)
			var x = SkillHelper.get_skill_flags_number(20000, EFFECT_ID, self.actorId, FLAG_NAME)
			var maxX = actor.get_level() * 2 - 1
			x = min(x + 1, maxX)
			SkillHelper.set_skill_flags(20000, EFFECT_ID, self.actorId, FLAG_NAME, x)
	return false
