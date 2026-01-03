extends "effect_20000.gd"

# 时乎主动技
#【时乎】大战场，主动技。无视距离选择1名队友，以体力上限临时减少 X 为代价，与其目标互换机动力。每2日限1次。X = 机动力差值。

const EFFECT_ID = 20710
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20710_start() -> void:
	var targetIds = []
	for targetId in get_teammate_targets(me, 999, true, true):
		var targetWA = DataManager.get_war_actor(targetId)
		if targetWA.action_point == me.action_point:
			continue
		targetIds.append(targetId)
	if not wait_choose_actors(targetIds, "选择队友发动【{0}】", true):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20710_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var diff = abs(me.action_point - targetWA.action_point)
	var current = actor.get_max_hp()
	if current < 10 + diff:
		var msg = "体力上限不足\n无法发动【{0}】\n（至少需要 {1}+10".format([
			ske.skill_name, diff,
		])
		play_dialog(actorId, msg, 3, 2999)
		return
	var msg = "体力上限 -{0}（现为{1}\n与{2}互换机动力\n可否？".format([
		diff, current, targetWA.get_name(),
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20710_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var diff = me.action_point - targetWA.action_point
	ske.cost_war_cd(2)
	ske.change_actor_max_hp(actorId, -abs(diff), 10)
	ske.change_actor_ap(actorId, -diff)
	ske.change_actor_ap(targetId, diff)
	var msg = "时乎，时乎\n会有变时！"
	report_skill_result_message(ske, 2002, msg, 0)
	return

func on_view_model_2002() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20710_report() -> void:
	report_skill_result_message(ske, 2002)
	return
