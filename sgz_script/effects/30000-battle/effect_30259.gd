extends "effect_30000.gd"

#直言小战场效果
#【直言】大战场，主动技。你可指定一个友军武将，消耗X点机动力：令其五行刷新，且点数为x，同时使其下一次白刃战战术值+x。x=你的等级。而后你获得2回合 {迟滞}。每回合限1次。

const ACTIVE_EFFECT_ID = 20516

func on_trigger_30005() -> bool:
	var buffed = ske.get_war_skill_val_int_array(ACTIVE_EFFECT_ID, ske.actorId)
	if buffed.empty():
		return false
	var wa = DataManager.get_war_actor(ske.actorId)
	var x = buffed[0]
	var fromId = buffed[1]
	if x <= 0 or fromId != actorId:
		return false
	ske.set_war_skill_val([], 0, ACTIVE_EFFECT_ID, ske.actorId)
	ske.battle_change_tactic_point(x, wa)
	ske.battle_report()

	var msg = "{0}故狂直，其言也恳切！\n（因{1}【{2}】战术值 +{3}".format([
		DataManager.get_actor_honored_title(actorId, ske.actorId),
		actor.get_name(), ske.skill_name, x,
	])
	wa.attach_free_dialog(msg, 0, 30000)
	return false
