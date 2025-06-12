extends "effect_20000.gd"

#忠谏诱发技，及忧患效果
#【忠谏】大战场，诱发技。我方主将发动计策后失败时，你可减10体发动谏言，其恢复计策消耗的一半机动力，并使其本回合计策命中率+10%。每回合限1次。
#【忧患】大战场，锁定技。你每次发动<忠谏>，令随机1名受伤的队友的恢复10点体力。

const EFFECT_ID = 20433
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const HP_COST = 10
const RATE_BUFF = 10

func on_trigger_20012()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.succeeded > 0:
		return false
	if ske.actorId == actorId:
		return false
	if ske.actorId != me.get_main_actor_id():
		return false
	if se.get_action_id(actorId) != ske.actorId:
		return false
	if ske.get_war_skill_val_int() > 0:
		return false
	if actor.get_hp() <= HP_COST:
		return false
	var target = DataManager.get_war_actor(ske.actorId)
	if target == null or target.disabled:
		return false
	# 设置发动标记，以免重复触发
	ske.set_war_skill_val(1, 1)
	return true

func effect_20433_start()->void:
	var target = DataManager.get_war_actor(ske.actorId)
	var msg = "体力减{0}\n对{2}发动【{1}】\n可否？".format([
		HP_COST, ske.skill_name, target.get_name(),
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000()->void:
	wait_for_yesno(FLOW_BASE + "_go", true, FLOW_BASE + "_end")
	return

func effect_20433_go()->void:
	var se = DataManager.get_current_stratagem_execution()
	var targetId = ske.actorId
	ske.cost_war_cd(1)
	var ap = int(se.cost / 2)
	ske.change_actor_hp(actorId, -HP_COST, 1)
	if ap > 0:
		ske.change_actor_ap(targetId, ap)
	ske.change_actor_scheme_chance(targetId, RATE_BUFF)
	var recover = 0
	if SkillHelper.actor_has_skills(actorId, ["忧患"]):
		var candidateIds = []
		for teammateId in get_teammate_targets(me, 999):
			var teammate = ActorHelper.actor(teammateId)
			if not teammate.is_injured():
				continue
			candidateIds.append(teammateId)
		if not candidateIds.empty():
			candidateIds.shuffle()
			recover = ske.change_actor_hp(candidateIds[0], HP_COST)
	ske.war_report()

	var msg = "计当慎出，不可轻忽\n良药苦口，望{0}善纳忠言".format([
		DataManager.get_actor_honored_title(ske.actorId, actorId),
	])
	report_skill_result_message(ske, 2001, msg, 3)
	return

func on_view_model_2001()->void:
	wait_for_pending_message(FLOW_BASE + "_report", FLOW_BASE + "_end")
	return

func effect_20433_report()->void:
	report_skill_result_message(ske, 2001)
	return

func effect_20433_end()->void:
	ske.set_war_skill_val(0, 0)
	skill_end_clear()
	return
