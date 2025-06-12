extends "effect_20000.gd"

#仇海主动技
#【仇海】大战场，主将限定技。直到回合结束前，禁用敌方所有附加技能。

const EFFECT_ID = 20545
const FLOW_BASE = "effect_" + str(EFFECT_ID)

# 发动主动技
func effect_20545_start() -> void:
	var msg = "发动【{0}】\n本回合内，禁用{1}全军附加技能，可否？".format([
		ske.skill_name, me.get_enemy_leader().get_name(),
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_2")
	return

func effect_20545_2() -> void:
	ske.cost_war_cd(99999)
	var banned = 0
	for wa in me.get_enemy_war_actors():
		var basics = SkillHelper.get_actor_unlocked_skill_names(wa.actorId).values()
		for skill in SkillHelper.get_actor_skills(wa.actorId):
			if skill.name in basics:
				continue
			ske.ban_war_skill(wa.actorId, skill.name, 1)
			banned += 1
	ske.war_report()

	if banned == 0:
		var msg = "竟无效用！却是何故 …"
		play_dialog(actorId, msg, 3, 2999)
		return

	var msg = "{0}，花巧无用\n项上人头，与我取来！".format([
		DataManager.get_actor_naughty_title(me.get_enemy_leader().actorId, actorId)
	])
	report_skill_result_message(ske, 2001, msg, 0, actorId, false)
	return

func on_view_model_2001():
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20545_report():
	report_skill_result_message(ske, 2001)
	return
