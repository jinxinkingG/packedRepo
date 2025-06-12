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

	return false
