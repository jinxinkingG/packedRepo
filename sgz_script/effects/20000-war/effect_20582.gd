extends "effect_20000.gd"

# 默罪效果
#【默罪】大战场，锁定技。你成为其他武将的主动技能目标后，你的机动力-1，对方机动力+1。

func on_trigger_20040()->bool:
	var prevSkeData = DataManager.get_env_dict("战争.完成技能")
	if prevSkeData.empty():
		return false
	var prevSke = SkillEffectInfo.new()
	prevSke.input_data(prevSkeData)
	if prevSke.effect_type != "主动":
		return false
	if prevSke.actorId == actorId:
		return false
	if prevSke.targetId != actorId:
		return false
	ske.change_actor_ap(actorId, -1)
	ske.change_actor_ap(prevSke.actorId, 1)
	ske.war_report()

	var from = DataManager.get_war_actor(prevSke.actorId)
	var msg = "{0}之意，{1}领会得".format([
		DataManager.get_actor_honored_title(from.actorId, actorId),
		DataManager.get_actor_self_title(actorId),
	])
	var mood = 2
	if me.is_enemy(from):
		msg = "承{0}青眼，必有回报".format([
			DataManager.get_actor_naughty_title(from.actorId, actorId),
		])
		mood = 0
	msg += "\n（【{0}】机动力 -1\n（{1}机动力 +1".format([
		ske.skill_name, from.get_name(),
	])
	me.attach_free_dialog(msg, mood)
	return false
