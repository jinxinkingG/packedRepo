extends "effect_20000.gd"

#窃功效果
#【窃功】大战场，锁定技。你方其他武将使用计策结算后，你的机动力+5，其机动力-5。每个回合限1次

const STEAL_AP = 5

func on_trigger_20012():
	if ske.actorId == actorId:
		return false
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(actorId) != ske.actorId:
		return false
	if me == null or me.disabled:
		return false
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.action_point < STEAL_AP:
		# 目标剩余机动力不足，不发动
		return false
	var stolen = ske.change_actor_ap(ske.actorId, -STEAL_AP)
	if stolen >= 0:
		return false
	ske.cost_war_cd(1)
	ske.change_actor_ap(actorId, -stolen)
	# 跳过连策以及时呈现对话
	se.skip_redo = 1
	var msg = ""
	if se.succeeded > 0:
		msg = "{0}侥幸计成\n亦赖吾建言之功也".format([
			DataManager.get_actor_naughty_title(ske.actorId, actorId),
		])
	else:
		msg = "{0}大意失计\n非吾建言之过也".format([
			DataManager.get_actor_naughty_title(ske.actorId, actorId),
		])
	msg += "\n（{0}窃取{1}机动力".format([
		me.get_name(), abs(stolen),
	])
	me.attach_free_dialog(msg, 1)
	ske.war_report()
	return false
