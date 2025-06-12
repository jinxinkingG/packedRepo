extends "effect_20000.gd"

# 设援主将限定技 #解锁技能
#【设援】大战场，主将限定技。你可以指定一个己方武将，直到本场战争结束前：若其没有<援护>，你令其获得<援护>；若其已拥有<援护>，你令其“统”+10。

const EFFECT_ID = 20591
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const TARGET_SKILL = "援护"

func effect_20591_start() -> void:
	if not wait_choose_actors(get_teammate_targets(me)):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20591_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var msg = "发动【{0}】\n令{1}临时获得【{2}】"
	if SkillHelper.actor_has_skills(targetId, [TARGET_SKILL]):
		msg = "{1}已习得【{2}】\n临时令其统率 +10"
	msg = msg.format([
		ske.skill_name, ActorHelper.actor(targetId).get_name(), TARGET_SKILL,
	]) + "\n可否？"
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20591_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	ske.cost_war_cd(99999)
	if SkillHelper.actor_has_skills(targetId, [TARGET_SKILL]):
		ske.change_war_leadership(targetId, 10)
	else:
		ske.add_war_skill(targetId, TARGET_SKILL, 99999)
	var msg = "{0}治军甚善\n吾以全军相托".format([
		DataManager.get_actor_honored_title(targetId, ske.skill_actorId),
	])
	play_dialog(actorId, msg, 0, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_response")
	return

func effect_20591_response():
	var targetId = get_env_int("目标")
	var msg = "谨受命，必呼应周全！"
	report_skill_result_message(ske, 2003, msg, 0, targetId)
	return

func on_view_model_2003() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20591_report() -> void:
	report_skill_result_message(ske, 2003)
	return
