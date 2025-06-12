extends "effect_20000.gd"

#休弈效果
#【休弈】大战场，主将锁定技。双方任意武将因技能效果进行位移时，对那次技能来源的武将，附加1回合“沉默”状态。

func on_trigger_20040() -> bool:
	var prevSkeData = DataManager.get_env_dict("战争.完成技能")
	if prevSkeData.empty():
		return false
	var prevSke = SkillEffectInfo.new()
	prevSke.input_data(prevSkeData)
	var target = null
	for r in prevSke.results:
		if r.type in ["互换位置", "移动"]:
			var wa = DataManager.get_war_actor(prevSke.skill_actorId)
			if wa == null or wa.disabled:
				continue
			target = wa
			break
	if target == null:
		return false
	ske.set_war_buff(target.actorId, "沉默", 1)
	ske.war_report()
	var msg = "兵凶战危，冒进必有代价"
	if "局" in prevSke.skill_name or "智" in prevSke.skill_name:
		msg = "兵凶战危，岂同纹枰论道"
	msg += "\n{0}且歇歇吧\n（发动【{1}】，{2}被沉默".format([
		DataManager.get_actor_honored_title(target.actorId, actorId),
		ske.skill_name, target.get_name(),
	])
	me.attach_free_dialog(msg, 2)
	return false
