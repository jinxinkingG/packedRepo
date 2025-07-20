extends "effect_20000.gd"

# 戒训主动技
#【戒训】大战场，主动技。选择1名武将为目标，令之获得或失去等同于其自身点数的机动力。每2回合限1次。

const EFFECT_ID = 20619
const FLOW_BASE = "effect_" + str(EFFECT_ID)


func effect_20619_start() -> void:
	var targets = []
	for targetId in get_teammate_targets(me):
		var wa = DataManager.get_war_actor(targetId)
		if wa.poker_point != 0:
			targets.append(targetId)
	for targetId in get_enemy_targets(me):
		var wa = DataManager.get_war_actor(targetId)
		if wa.poker_point != 0:
			targets.append(targetId)
	if targets.empty():
		var msg = "没有可以【{0}】的目标".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return
	wait_choose_actors(targets)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20619_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)
	var msg = "【{0}】{1}\n令其机动力：".format([
		ske.skill_name, wa.get_name()
	])
	var ap = str(wa.poker_point)
	var options = ["+" + ap, "-" + ap]
	play_dialog(actorId, msg, 2, 2001, true, options)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_add", true, FLOW_BASE + "_sub", false)
	return

func effect_20619_add() -> void:
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)

	var ap = ske.change_actor_ap(targetId, wa.poker_point)
	ske.cost_war_cd(2)
	ske.war_report()

	var name = DataManager.get_actor_naughty_title(targetId, actorId)
	if me.is_teammate(wa):
		name = DataManager.get_actor_honored_title(targetId, actorId)
	var msg = "{0}临机不决，更待何时？\n（{1}机动力 +{2} -> {3}".format([
		name, wa.get_name(), ap, wa.action_point
	])
	play_dialog(actorId, msg, 2, 2999)
	return

func effect_20619_sub() -> void:
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)

	var ap = ske.change_actor_ap(targetId, -wa.poker_point)
	ske.cost_war_cd(2)
	ske.war_report()

	var name = DataManager.get_actor_naughty_title(targetId, actorId)
	if me.is_teammate(wa):
		name = DataManager.get_actor_honored_title(targetId, actorId)
	var msg = "{0}知变不足，有何能为？\n（{1}机动力 {2} -> {3}".format([
		name, wa.get_name(), ap, wa.action_point
	])
	play_dialog(actorId, msg, 2, 2999)
	return
