extends "effect_20000.gd"

# 试觋主动技
#【试觋】大战场，主将主动技。你可以指定一个己方武将，立即刷新他的五行，若其点数为奇数，则将你的机动力转移10点给该武将；否则将你的兵力转移200给该武将。每回合限1次。

const EFFECT_ID = 20711
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const TRANSFER_AP = 10
const TRANSFER_SOLDIERS = 200

func effect_20711_start() -> void:
	if not assert_action_point(actorId, TRANSFER_AP):
		return
	if not assert_min_soldiers(TRANSFER_SOLDIERS):
		return
	var targets = get_teammate_targets(me)
	if not wait_choose_actors(targets, "选择队友发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20711_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var msg = "对{0}发动【{1}】\n刷新其五行点数\n可否？".format([
		targetWA.get_name(), ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20711_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	ske.change_actor_five_phases(targetId, -1, -1)
	ske.cost_war_cd(1)
	var msg = "（{0}五行现为：{1} {2}".format([
		targetWA.get_name(), targetWA.get_five_phases_str(),
		targetWA.poker_point,
	])
	if targetWA.poker_point % 2 == 1:
		var ap = ske.change_actor_ap(actorId, -TRANSFER_AP)
		ske.change_actor_ap(targetId, abs(ap))
		msg = "大哉乾元，万物资始\n" + msg + "\n（给予{0} {1}机动力".format([
			targetWA.get_name(), abs(ap),
		])
	else:
		var soldiers = ske.sub_actor_soldiers(actorId, TRANSFER_SOLDIERS)
		ske.add_actor_soldiers(targetId, soldiers)
		msg = "至哉坤元，万物资生\n" + msg + "\n（给予{0} {1}士兵".format([
			targetWA.get_name(), soldiers,
		])
	play_dialog(actorId, msg, 1, 2999)
	return
