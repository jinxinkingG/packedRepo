extends "effect_20000.gd"

# 雄才效果
#【雄才】大战场，锁定技。敌方发动主动技或诱发技后，你临时领悟该技能，发动或触发一次后失效；以 <雄才> 领悟的技能，最多保留三个。

func on_trigger_20040() -> bool:
	var prevSkeData = DataManager.get_env_dict("战争.完成技能")
	if prevSkeData.empty():
		return false
	var prevSke = SkillEffectInfo.new()
	prevSke.input_data(prevSkeData)
	if prevSke.skill_name in SkillHelper.get_actor_skill_names(actorId):
		return false
	learn_skill(prevSke.skill_name)
	return false

func on_trigger_20041() -> bool:
	var prevSkeData = DataManager.get_env_dict("战争.诱发技能")
	if prevSkeData.empty():
		return false
	var prevSke = SkillEffectInfo.new()
	prevSke.input_data(prevSkeData)
	if prevSke.skill_name in SkillHelper.get_actor_skill_names(actorId):
		return false
	learn_skill(prevSke.skill_name)
	return false

func learn_skill(skillName:String) -> void:
	var learned = ske.get_war_skill_val_array()
	if skillName in learned:
		return
	var count = learned.size()
	var removed = []
	if count >= 3:
		var refreshed = [learned[1], learned[2], skillName]
		removed = learned.slice(0, count - 3)
		learned = refreshed
	else:
		learned.append(skillName)
	for sn in removed:
		ske.remove_war_skill(actorId, sn)
	ske.add_war_skill(actorId, skillName, 99999, false, true)
	ske.set_war_skill_val(learned)
	ske.war_report()

	var msg = "上兵伐谋，不拘成法\n{0}之用，未尽其妙\n（【{1}】获得【{0}】".format([
		skillName, ske.skill_name,
	])
	me.attach_free_dialog(msg, 2)
	return
