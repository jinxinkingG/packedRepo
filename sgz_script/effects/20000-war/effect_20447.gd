extends "effect_20000.gd"

#杀绝锁定技
#【杀绝】大战场，锁定技。被你方击杀/俘虏的敌将，清空其剩余兵力，转化为你等量的经验值(不触发组队经验)。每场战争中，第一次触发后，你的德-1。

func on_trigger_20020()->bool:
	var bf = DataManager.get_current_battle_fight()
	if not ske.actorId in [bf.get_attacker_id(), bf.get_defender_id()]:
		return false
	var loser = bf.get_loser()
	if loser == null or loser.actorId == ske.actorId:
		return false
	if not loser.disabled:
		return false
	var soldiers = loser.get_soldiers()
	if soldiers <= 0:
		return false
	loser.actor().set_soldiers(0)
	ske.change_actor_exp(actorId, soldiers)
	ske.war_report()
	var msg = "败兵留之何用？\n（触发【{1}】\n（经验增加{2}".format([
		actor.get_name(), ske.skill_name, soldiers
	])
	var flag = ske.get_war_skill_val_int()
	if flag <= 0:
		ske.set_war_skill_val(1, 99999)
		var moral = actor.get_moral()
		if moral > 1:
			actor.set_moral(moral - 1)
			msg += "\n（本战首次触发，{0}德 -1".format([
				actor.get_name(),
			])
	me.attach_free_dialog(msg, 0)
	ske.war_report()
	return false
