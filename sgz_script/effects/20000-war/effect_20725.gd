extends "effect_20000.gd"

#讨难主动技
#【讨难】大战场，主动技。选择1名相邻的敌将发动。你与之进入白刃战，战争中限X次。（X=你的等级-1）

const EFFECT_ID = 20725
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const CD = 600

func get_times_limit() -> int:
	return int(max(1, actor.get_level() - 1))

func check_AI_perform_20000() -> bool:
	if me.war_vstate().delegated:
		skill_end_clear()
		return false
	var targets = get_combat_targets(me, true, 1, true, false)
	if targets.empty():
		return false
	# AI 选择兵力最少的相邻敌将
	var selectedId = -1
	var leastSoldiers = 999999
	for targetId in targets:
		var ta = ActorHelper.actor(targetId)
		var soldiers = ta.get_soldiers()
		if soldiers < leastSoldiers:
			leastSoldiers = soldiers
			selectedId = targetId
	if selectedId < 0:
		return false
	DataManager.set_env("目标", selectedId)
	return true

func effect_20725_AI_start() -> void:
	var targetId = DataManager.get_env_int("目标")
	ske.cost_war_limited_times(get_times_limit(), CD)
	ske.war_report()

	var msg = "冲锋破敌，平祸定乱\n本将职所也！\n（{0}对{1}发动【{2}】".format([
		me.get_name(), ActorHelper.actor(targetId).get_name(),
		ske.skill_name,
	])
	play_dialog(actorId, msg, 0, 2002)
	return

func effect_20725_start() -> void:
	var targets = get_combat_targets(me, true, 1, true, false)
	var msg = "选择相邻敌将发动【{0}】"
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_confirm_ask", true)
	return

func effect_20725_confirm_ask() -> void:
	var targetId = DataManager.get_env_int("目标")
	var msg = "冲锋破敌，平祸定乱\n本将职所也！\n（与{0}进入白刃战".format([
		ActorHelper.actor(targetId).get_name()
	])
	play_dialog(actorId, msg, 0, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_execute", true)
	return

func effect_20725_execute() -> void:
	var targetId = DataManager.get_env_int("目标")
	ske.cost_war_limited_times(get_times_limit(), CD)
	ske.war_report()
	start_battle_and_finish(actorId, targetId)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_battle")
	return

func effect_20725_battle() -> void:
	var targetId = DataManager.get_env_int("目标")
	start_battle_and_finish(actorId, targetId)
	return
