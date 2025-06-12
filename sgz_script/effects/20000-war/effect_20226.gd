extends "effect_20000.gd"

#迅策效果实现
#【迅策】大战场,锁定技。你伤兵类计策命中后，有30%概率造成200%暴击效果

const EFFECT_ID = 20226

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	if se.get_action_id(self.actorId) != self.actorId:
		return false
	# 可以考虑使用战场伪随机
	#if DataManager.pseduo_random_war() < 30:
	if Global.get_rate_result(30):
		change_scheme_damage_rate(100)
	return false
