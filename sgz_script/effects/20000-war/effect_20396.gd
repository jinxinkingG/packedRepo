extends "effect_20000.gd"

#符水主动技
#【符水】大战场，主动技。米＞500时，你可以指定一个你方机动力＞＝10的武将发动道术：米-100，该武将体+15，兵力+150，机动力-10。每个回合限1次

const EFFECT_ID = 20396
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const RICE_MIN = 501
const RICE_COST = 100
const AP_COST = 10
const HP_RECOVER = 15
const SOLDIERS_RECOVER = 150

func effect_20396_start():
	var wv = me.war_vstate()
	if wv.rice < RICE_MIN:
		play_dialog(me.actorId, "米不足，需 >= {0}".format([RICE_MIN]), 3, 2999)
		return
	var targets = []
	var candidates = get_teammate_targets(me)
	candidates.append(me.actorId)
	for targetId in candidates:
		var targetWA = DataManager.get_war_actor(targetId)
		if targetWA.action_point < AP_COST:
			continue
		var targetActor = ActorHelper.actor(targetId)
		if targetActor.is_injured():
			targets.append(targetId)
			continue
		if targetActor.get_soldiers() < DataManager.get_actor_max_soldiers(targetId):
			targets.append(targetId)
			continue
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20396_2():
	var targetId = get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var msg = "消耗{0}米\n令{1}略作休整\n可否？".format([
		RICE_COST, targetWA.get_name(),
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20396_3():
	var targetId = get_env_int("目标")

	ske.cost_war_cd(1)
	ske.cost_wv_rice(RICE_COST)
	ske.change_actor_ap(targetId, -AP_COST)
	ske.change_actor_hp(targetId, HP_RECOVER)
	ske.add_actor_soldiers(targetId, SOLDIERS_RECOVER, 2500)

	var msg = "道朴如海，符箓为引\n{0}可稍歇再战".format([
		DataManager.get_actor_honored_title(targetId, me.actorId),
	])
	report_skill_result_message(ske, 2002, msg, 1)
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_4")
	return

func effect_20396_4():
	report_skill_result_message(ske, 2002)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return
