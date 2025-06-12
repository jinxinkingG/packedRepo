extends "effect_20000.gd"

# 违忤主动技及浑疆效果 #机动力 #施加状态
#【违忤】大战场,限定技。你可以选择1名队友发动。你获得其全部机动力，之后对你自身附加1回合定止状态。
#【浑疆】大战场，锁定技。你方主将发动<违忤>时，若指定的目标不是你，则你也获得其因<违忤>效果得到的机动力。


const EFFECT_ID = 20235
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20235_start() -> void:
	var targets = []
	for targetId in get_teammate_targets(me):
		var wa = DataManager.get_war_actor(targetId)
		if wa.action_point <= 0:
			continue
		targets.append(targetId)
	if not wait_choose_actors(targets, "选择队友发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20235_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var msg = "发动限定技【{0}】\n夺取{1} {2} 机动力\n可否？".format([
		ske.skill_name, targetWA.get_name(), targetWA.action_point
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20235_confirmed():
	var targetId = DataManager.get_env_int("目标")

	ske.cost_war_cd(99999)
	var ap = ske.clear_actor_ap(targetId)
	ske.change_actor_ap(ske.skill_actorId, -ap)
	ske.set_war_buff(ske.skill_actorId, "定止", 1)
	if me.get_main_actor_id() == actorId:
		for wa in me.get_teammates(false, true):
			if wa.actorId == targetId:
				continue
			if SkillHelper.actor_has_skills(wa.actorId, ["浑疆"]):
				ske.change_actor_ap(wa.actorId, -ap)
	ske.war_report()

	map.update_ap()

	var msg = "时事变幻，不可拘泥\n{0}，都交给我吧".format([
		DataManager.get_actor_naughty_title(targetId, ske.skill_actorId)
	])
	report_skill_result_message(ske, 2002, msg, 1)
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20235_report():
	report_skill_result_message(ske, 2002)
	return
