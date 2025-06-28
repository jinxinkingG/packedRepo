extends "effect_20000.gd"

#教守主将限定技 #解锁技能
#【教守】大战场，主将限定技。你可以指定一个己方武将，直到本场战争结束前：若其没有<武守>，你令其获得<武守>；若其已拥有<武守>，你令其“胆”+10。

const EFFECT_ID = 20435
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const TARGET_SKILL = "武守"
const BUFFED = 10

func effect_20435_start() -> void:
	if not wait_choose_actors(get_teammate_targets(me)):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20435_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var buffed = ske.get_war_skill_val_dic()
	if str(targetId) in buffed and Global.intval(buffed[str(targetId)]) == 2:
		var msg = "{0}当速出击！\n（不可重复提升属性".format([
			DataManager.get_actor_honored_title(targetId, actorId)
		])
		play_dialog(actorId, msg, 2, 2999)
		return

	var msg = "发动【{0}】\n令{1}临时获得【{2}】"
	if SkillHelper.actor_has_skills(targetId, [TARGET_SKILL]):
		msg = "{1}已习得【{2}】\n临时令其胆 +10"
	msg = msg.format([
		ske.skill_name, ActorHelper.actor(targetId).get_name(), TARGET_SKILL,
	]) + "\n可否？"
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20435_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	ske.cost_war_cd(99999)
	var buffed = ske.get_war_skill_val_dic()
	if SkillHelper.actor_has_skills(targetId, [TARGET_SKILL]):
		ske.change_war_courage(targetId, BUFFED)
		buffed[str(targetId)] = 2
	else:
		ske.add_war_skill(targetId, TARGET_SKILL, 99999)
		buffed[str(targetId)] = 1
	ske.set_war_skill_val(buffed)
	var msg = "{0}为我军柱石\n吾寄望甚深".format([
		DataManager.get_actor_honored_title(targetId, ske.skill_actorId),
	])
	play_dialog(actorId, msg, 0, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_response")
	return

func effect_20435_response() -> void:
	var targetId = DataManager.get_env_int("目标")
	var msg = "谨受命，必破来犯之敌！"
	report_skill_result_message(ske, 2003, msg, 0, targetId)
	return

func on_view_model_2003() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20435_report() -> void:
	report_skill_result_message(ske, 2003)
	return
