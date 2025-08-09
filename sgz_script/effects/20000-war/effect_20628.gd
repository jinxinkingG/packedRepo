extends "effect_20000.gd"

# 谬拥限定技
#【谬拥】大战场，限定技。若你方主将不是君主，你需选择1名与君主同姓的队友为目标发动。拥立目标成为你方主将，使之附加<暴威>和<独揽>技能，并禁用你自身的所有技能，持续X回合（X=9-目标德/10，其中1≤X≤9，取整）。

const EFFECT_ID = 20628
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20628_start() -> void:
	var lord = me.war_vstate().get_lord()
	var leader = me.get_leader()
	if leader.actorId == lord.actorId:
		var msg = "主将为君主，不可发动"
		play_dialog(actorId, msg, 2, 2999)
		return

	var targetIds = []
	for targetId in get_teammate_targets(me):
		var wa = DataManager.get_war_actor(targetId)
		if wa.actorId == leader.actorId:
			continue
		if wa.actor().get_first_name() == lord.get_first_name():
			targetIds.append(targetId)
	if targetIds.empty():
		var msg = "没有君主同宗，不可发动"
		play_dialog(actorId, msg, 2, 2999)
		return

	if not wait_choose_actors(targetIds, "【{0}】何人？"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20628_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var msg = "【{0}】{1}\n令替{2}为主将\n可否？".format([
		ske.skill_name, ActorHelper.actor(targetId).get_name(),
		me.get_leader().get_name(),
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20628_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	var msg = "{0}英明果断，有主公风范\n当为三军之主".format([
		DataManager.get_actor_honored_title(targetId, actorId),
	])
	play_dialog(actorId, msg, 2, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_change")
	return

func effect_20628_change() -> void:
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)

	ske.cost_war_cd(99999)
	me.war_vstate().main_actorId = targetId
	var x = 9 - int(wa.actor().get_moral() / 10)
	x = max(1, x)
	x = min(9, x)
	ske.add_war_skill(targetId, "暴威", x)
	ske.add_war_skill(targetId, "独揽", x)
	for skillName in SkillHelper.get_actor_skill_names(actorId):
		ske.ban_war_skill(actorId, skillName, x)
	ske.war_report()

	var msg = "{0}溢美太过\n然统军重任，{1}不敢辞！\n（{2}成为主将".format([
		DataManager.get_actor_honored_title(actorId, targetId),
		wa.actor().get_short_name(), wa.get_name(),
	])
	report_skill_result_message(ske, 2003, msg, 0, targetId, false)
	return

func on_view_model_2003() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20628_report() -> void:
	report_skill_result_message(ske, 2003)
	return
