extends "effect_20000.gd"

#仁恕锁定技
#【仁恕】大战场，主将锁定技。同一回合内，你方任意1名队友累计用计失败达到3次时，其机动力+15，回合内每名武将只能触发1次。

const AP_AWARD = 15

func on_trigger_20012()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(actorId) != ske.actorId:
		return false
	if se.succeeded > 0:
		return false
	var key = str(ske.actorId)
	var failures = ske.get_war_skill_val_dic()
	if not key in failures:
		failures[key] = 0
	failures[key] += 1
	ske.set_war_skill_val(failures, 1)
	if failures[key] < 3:
		return false
	failures[key] = -99999
	ske.set_war_skill_val(failures, 1)
	var ap = ske.change_actor_ap(ske.actorId, AP_AWARD)
	var msg = "成败兵家常事\n{0}再接再励\n（【{1}】{2}机动力 +{3}".format([
		DataManager.get_actor_honored_title(ske.actorId, actorId),
		ske.skill_name, ActorHelper.actor(ske.actorId).get_name(), ap,
	])
	me.attach_free_dialog(msg, 2)
	return false
