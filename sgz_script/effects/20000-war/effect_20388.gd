extends "effect_20000.gd"

#晓密效果和绝亲效果，实现为锁定技
#【晓密】大战场，诱发技。对方回合，等级不大于你的敌方武将因技能获得机动力后才能发动。将其总机动力扣减一半。每回合限一次。
#【绝亲】大战场，锁定技。你发动<晓密>减少敌将机动力时，那名敌将与你同姓，则其减少的部分机动力由你获得。
# TODO, 未完成版本，目前只能支持主动技，锁定技和诱发技连锁暂未支持

func on_trigger_20040() -> bool:
	var prevSkeData = DataManager.get_env_dict("战争.完成技能")
	if prevSkeData.empty():
		return false
	var prevSke = SkillEffectInfo.new()
	prevSke.input_data(prevSkeData)
	var target = null
	for r in prevSke.results:
		if r.type == "机动力" and r.actorId >= 0:
			var wa = DataManager.get_war_actor(r.actorId)
			if not me.is_enemy(wa):
				continue
			if wa.actor().get_level() > actor.get_level() or wa.action_point < 2:
				continue
			target = wa
			break
	if target == null:
		return false
	var reduced = int(target.action_point / 2)
	if reduced <= 0:
		return false
	ske.change_actor_ap(target.actorId, -reduced)
	if SkillHelper.actor_has_skills(actorId, ["绝亲"]):
		if target.actor().get_first_name() == actor.get_first_name():
			ske.change_actor_ap(actorId, reduced)
	ske.cost_war_cd(1)
	ske.war_report()
	var msg = "{0}谋事不密\n失机理所当然\n（{1}失去{2}机动力".format([
		DataManager.get_actor_naughty_title(target.actorId, actorId),
		target.get_name(), reduced,
	])
	append_free_dialog(me, msg, 1)
	return false
