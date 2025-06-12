extends "effect_20000.gd"

#忘隙效果实现
#【忘隙】大战场,锁定技。只要你在战场，敌方计策每失败1次，己方忠最低的1名武将忠+1（至多升至90）。

const EFFECT_ID = 20258

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	if ske.actorId == self.actorId:
		return false
	var se = DataManager.get_current_stratagem_execution()
	if se.succeeded > 0:
		return false
	if se.get_action_id(self.actorId) != ske.actorId:
		return false
	var me = DataManager.get_war_actor(self.actorId)
	if me == null or me.disabled:
		return false
	var leastLoyal = -1
	var leastLoyalVal = 99
	for targetId in get_teammate_targets(me, 9999):
		var loy = ActorHelper.actor(targetId).get_loyalty()
		if loy >= 90:
			continue
		if loy < leastLoyalVal:
			leastLoyalVal = loy
			leastLoyal = targetId
	if leastLoyal < 0:
		return false
	var targetActor = ActorHelper.actor(leastLoyal)
	targetActor.set_loyalty(targetActor.get_loyalty() + 1)
	var msg = "因{0}【{1}】效果\n{2}忠+1，现为{3}".format([
		me.get_name(), ske.skill_name,
		targetActor.get_name(), targetActor.get_loyalty(),
	])
	se.append_result(ske.skill_name, msg, 1, leastLoyal)
	return false
