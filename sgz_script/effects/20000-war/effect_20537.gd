extends "effect_20000.gd"

#平讨主动技
#【平讨】大战场，主动技。你可指定1名敌将，令其选择一项：1.将3点机动力交给你；2.令你视为对其进行了一次攻击宣言。每回合限1次。

const EFFECT_ID = 20537
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const LOSS_AP = 3

func check_AI_perform_20000()->bool:
	if false and actor.get_hp() < 50:
		return false
	var selectedId = -1
	var leastPower = 250 * 1000
	for targetId in get_enemy_targets(me):
		var targetActor = ActorHelper.actor(targetId)
		# 模拟计算士气
		var morale = me.calculate_battle_morale(targetActor.get_power(), targetActor.get_leadership())
		var power = morale * targetActor.get_soldiers()
		if power < leastPower:
			leastPower = power
			selectedId = targetId
	if selectedId < 0:
		return false
	DataManager.set_env("目标", selectedId)
	return true

func effect_20537_AI_start():
	goto_step("2")
	return

func effect_20537_start():
	var targets = get_enemy_targets(me)
	if not wait_choose_actors(targets, "选择敌军发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_2", true)
	return

func effect_20537_2():
	var targetId = DataManager.get_env_int("目标")

	ske.cost_war_cd(1)

	var msg = "{1}小儿，可敢一战！\n（{0}对{1}发动【{2}】".format([
		me.get_name(), ActorHelper.actor(targetId).get_name(),
		ske.skill_name,
	])
	play_dialog(actorId, msg, 0, 2001)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20537_3() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	if targetWA.action_point < LOSS_AP:
		goto_step("fight")
		return
	var ctrlNo = targetWA.get_controlNo()
	if ctrlNo < 0:
		# 有机动力的情况下，AI 总是避战
		goto_step("scared")
		return
	var options = ["何惧之有？", "暂避锋芒"]
	var msg = "避战将机动力 -3，是否迎战？"
	SceneManager.show_yn_dialog(msg, targetId, 2, options)
	LoadControl.set_view_model(2002)
	return

func on_view_model_2002() -> void:
	match wait_for_skill_option():
		0:
			goto_step("fight")
		1:
			goto_step("scared")
	return

func effect_20537_fight() -> void:
	var targetId = DataManager.get_env_int("目标")
	ske.war_report()
	start_battle_and_finish(actorId, targetId)
	return

func effect_20537_scared() -> void:
	var targetId = DataManager.get_env_int("目标")
	var lost = ske.change_actor_ap(targetId, -LOSS_AP)
	var got = ske.change_actor_ap(actorId, LOSS_AP)
	ske.war_report()
	var msg = "..."
	report_skill_result_message(ske, 2003, msg, 3, targetId, false)
	return

func effect_20537_report() -> void:
	report_skill_result_message(ske, 2003)
	return

func on_view_model_2003() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return
