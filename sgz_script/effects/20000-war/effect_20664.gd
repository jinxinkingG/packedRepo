extends "effect_20000.gd"

# 孛明效果
#【孛明】大战场，锁定技。战争开始时，你夜观流星：有50%概率使你的兵力回复至兵力上限。

func on_trigger_20019() -> bool:
	ske.cost_war_cd(99999)
	var soldiers = ske.get_war_skill_val_int()
	if soldiers > 0:
		return false
	var limit = DataManager.get_actor_max_soldiers(actorId)
	var current = actor.get_soldiers()
	if current >= limit:
		return false

	var notifiedBy = -1
	for srb in SkillRangeBuff.find_for_war_vstate("天象", me.wvId):
		if srb.effectTagVal > 0:
			notifiedBy = srb.actorId
			break
	if notifiedBy >= 0 or Global.get_rate_result(50):
		soldiers = ske.add_actor_soldiers(actorId, limit - current, limit)
		ske.set_war_skill_val(soldiers)
	ske.war_report()

	if soldiers <= 0:
		return false

	if notifiedBy >= 0:
		var msg = "天象有变，应在此战\n{0}以为如何".format([
			DataManager.get_actor_honored_title(actorId, notifiedBy)
		])
		me.attach_free_dialog(msg, 2, 20000, notifiedBy)
	var msg = "孛星冲月，天意在我\n{0}败亡，当在今夜！\n（义士云集，士兵恢复 {1}".format([
		DataManager.get_actor_naughty_title(me.get_enemy_leader().actorId, actorId),
		soldiers
	])
	me.attach_free_dialog(msg, 0)
	return false
