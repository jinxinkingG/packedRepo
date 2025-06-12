extends "effect_20000.gd"

#笃行主动技
#【笃行】大战场，锁定技。你每使用一次大战场主动技，你的机动力+5，每回合限3次。

const GAIN_AP = 5
const TIMES_LIMIT = 3

func on_trigger_20040()->bool:
	var prevSkeData = DataManager.get_env_dict("战争.完成技能")
	if prevSkeData.empty():
		return false
	var prevSke = SkillEffectInfo.new()
	prevSke.input_data(prevSkeData)
	if prevSke.effect_type != "主动":
		return false

	if not ske.cost_war_limited_times(TIMES_LIMIT):
		return false
	var changed = ske.change_actor_ap(actorId, GAIN_AP)
	ske.war_report()
	
	var msg = "明辨笃行，道所在也\n（因【{0}】效果\n（{1}机动力+{2}".format([
		ske.skill_name, me.get_name(), changed,
	])
	me.attach_free_dialog(msg)
	return false
