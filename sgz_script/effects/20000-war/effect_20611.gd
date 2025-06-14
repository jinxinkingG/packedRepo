extends "effect_20000.gd"

# 巡疾主动技
#【巡疾】大战场，主动技。指定一名受伤的队友为目标发动。目标体力恢复至满，你受到其恢复体力数值一半的伤害。每回合限1次。（允许过载而死。）

const EFFECT_ID = 20611
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20611_start() -> void:
	var targetIds = []
	for targetId in get_teammate_targets(me):
		var teammate = DataManager.get_war_actor(targetId)
		if not teammate.actor().is_injured():
			continue
		targetIds.append(targetId)
	if targetIds.empty():
		var msg = "队友均未受伤"
		play_dialog(actorId, msg, 1, 2999)
		return
	if not wait_choose_actors(targetIds):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20611_selected()->void:
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)

	var msg = "不避瘴疫\n为{0}恢复全部体力\n可否？".format([
		wa.get_name(),
	])
	play_dialog(actorId, msg, 2, 2001, true)
	map.next_shrink_actors = [targetId, actorId]
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20611_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)
	var recover = wa.actor().get_max_hp() - wa.actor().get_hp()
	var damage = int(recover / 2)

	if damage < actor.get_hp():
		goto_step("anyway")
		return

	var msg = "{0}连日巡疾辛苦，已失色矣\n万万保重，不可逞强！".format([
		DataManager.get_actor_honored_title(actorId, wa.actorId)
	])
	var options = ["小命要紧", "坚持发动"]
	play_dialog(wa.actorId, msg, 3, 2002, true, options)
	return

func on_view_model_2002() -> void:
	wait_for_yesno(FLOW_BASE + "_cancel", true, FLOW_BASE + "_anyway")
	return

func effect_20611_cancel() -> void:
	var targetId = DataManager.get_env_int("目标")
	var msg = "不善己身，何以善众\n幸得{0}良言相劝".format([
		DataManager.get_actor_honored_title(targetId, actorId)
	])
	play_dialog(actorId, msg, 2, 2999)
	return

func effect_20611_anyway() -> void:
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)
	var recover = wa.actor().get_max_hp() - wa.actor().get_hp()
	var damage = int(recover / 2)

	ske.change_actor_hp(wa.actorId, recover)
	ske.change_actor_hp(actorId, -damage)
	ske.cost_war_cd(1)
	ske.war_report()

	report_skill_result_message(ske, 2003)
	return

func on_view_model_2003() -> void:
	wait_for_pending_message(FLOW_BASE + "_report", FLOW_BASE + "_end")
	return

func effect_20611_report() -> void:
	report_skill_result_message(ske, 2003)
	return

func effect_20611_end() -> void:
	if actor.get_hp() < 0:
		actor.set_hp(-1)
		me.dead(ske.skill_name)
		var targetId = DataManager.get_env_int("目标")
		var msg = "{0}何以一意孤行！\n（{1}染疾猝亡".format([
			DataManager.get_actor_honored_title(actorId, targetId),
			actor.get_name(),
		])
		play_dialog(targetId, msg, 3, 2999)
		return
	FlowManager.add_flow("player_skill_end_trigger")
	return
