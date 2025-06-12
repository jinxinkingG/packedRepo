extends "effect_30000.gd"

#双雄小战场对话 #战吼
#【双雄】小战场,锁定技。你的武临时+（x*你的等级），战术值+x，x＝你方场上拥有<双雄>的人数，最大为2。

func on_trigger_30006()->bool:
	var x = 1
	for wa in me.war_vstate().get_war_actors(false, true):
		if wa.actorId == me.actorId:
			continue
		if SkillHelper.actor_has_skills(wa.actorId, ["双雄"]):
			x = 2
			break

	var sbp = ske.get_battle_skill_property()
	sbp.power += x * actor.get_level()
	sbp.tp += x
	ske.apply_battle_skill_property(sbp)
	ske.battle_report()

	var msg = "{0}在此!\n可知我双雄威名!".format([
		DataManager.get_actor_self_title(me.actorId),
	])
	me.attach_free_dialog(msg, 0, 30000)
	return false
