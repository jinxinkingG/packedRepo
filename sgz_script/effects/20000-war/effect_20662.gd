extends "effect_20000.gd"

# 惧责诱发技
#【惧责】大战场，诱发技。你被攻击或用计时可以发动。取消之，同时可选择另一名敌将（可选城地形），调换其与发动者的机动力。每回合限1次。

const EFFECT_ID = 20662
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20015()->bool:
	var bf = DataManager.get_current_battle_fight()
	return bf.get_defender_id() == actorId

func on_trigger_20038()->bool:
	var se = DataManager.get_current_stratagem_execution()
	return se.targetId == actorId

func effect_20662_AI_start() -> void:
	goto_step("start")
	return

func effect_20662_start() -> void:
	var fromActor = ActorHelper.actor(ske.actorId)

	var msg = "{0}规避{1}的{2}"
	var action = "攻击"
	if ske.trigger_Id == 20038:
		var se = DataManager.get_current_stratagem_execution()
		action = se.name
		fromActor = ActorHelper.actor(se.fromId)
		# 跳过一下，不然不记录日志
		se.skip_execution(actorId, ske.skill_name)
		se.report()
	else:
		var bf = DataManager.get_current_battle_fight()
		bf.skip_execution(actorId, ske.skill_name)
		bf.war_report()
		fromActor = ActorHelper.actor(bf.get_attacker_id())
	msg = msg.format([
		me.get_name(), fromActor.get_name(), action
	])

	# 标记发动者
	ske.set_war_skill_val(fromActor.actorId, 1)
	ske.cost_war_cd(1)
	ske.append_message(msg)

	msg = "兵连祸结，何独责于我\n（" + msg
	play_dialog(actorId, msg, 3, 2000)
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_avoided")
	return

func effect_20662_avoided() -> void:
	var fromActorId = ske.get_war_skill_val_int()
	if fromActorId < 0:
		goto_step("end")
		return
	var targets = get_enemy_targets(me, true)
	targets.erase(fromActorId)
	if targets.empty():
		goto_step("end")
		return
	var msg = "选择敌军，与{0}交换机动力".format([
		ActorHelper.actor(fromActorId).get_name(),
	])
	wait_choose_actors(targets, msg, true)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected", false, false)
	return

func effect_20662_selected() -> void:
	var fromActorId = ske.get_war_skill_val_int()
	var targetId = DataManager.get_env_int("目标")
	var fromWA = DataManager.get_war_actor(fromActorId)
	var targetWA = DataManager.get_war_actor(targetId)

	var apDiff = fromWA.action_point - targetWA.action_point

	ske.change_actor_ap(fromWA.actorId, -apDiff)
	ske.change_actor_ap(targetWA.actorId, apDiff)
	var msg = "{0}的机动力现为 {1}\n{2}的机动力现为 {3}".format([
		fromWA.get_name(), fromWA.action_point,
		targetWA.get_name(), targetWA.action_point,
	])
	play_dialog(-1, msg, 2, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_end")
	return

func effect_20662_end() -> void:
	ske.war_report()
	LoadControl.end_script()
	SkillHelper.remove_current_skill_trigger()

	map.cursor.hide()
	map.clear_can_choose_actors()
	var nextFlow = "AI_before_ready"
	if me.get_controlNo() < 0:
		nextFlow = "player_ready"
	FlowManager.add_flow(nextFlow)
	return
