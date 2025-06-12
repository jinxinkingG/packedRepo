extends "effect_20000.gd"

#复策诱发技
#【复策】大战场，诱发技。你方武将用计失败的场合可以发动，你可使其无消耗再发动1次该计策。每回合限1次。

const EFFECT_ID = 20418
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20012()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.succeeded > 0:
		return false
	var actionId = se.get_action_id(me.actorId)
	if actionId < 0 or actionId == me.actorId:
		# 隐身用计或是我发动
		return false
	var targetWA = DataManager.get_war_actor(se.targetId)
	if targetWA == null:
		# 必须有目标
		return false
	if not targetWA.is_enemy(me):
		# 队友不发动
		return false
	return true

func effect_20418_AI_start()->void:
	goto_step("redo")
	return

func effect_20418_start()->void:
	var se = DataManager.get_current_stratagem_execution()
	var actionId = se.get_action_id(me.actorId)
	var msg = "令{0}再次发动{1}\n可否？".format([
		ActorHelper.actor(actionId).get_name(), se.name,
	])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func on_view_model_2000()->void:
	wait_for_yesno(FLOW_BASE + "_redo", false)
	return

func effect_20418_redo()->void:
	var se = DataManager.get_current_stratagem_execution()
	var actionId = se.get_action_id(me.actorId)
	var msg = "此计不成，敌或骄慢\n{0}复往，当可出奇致胜".format([
		DataManager.get_actor_honored_title(actionId, me.actorId)
	])
	play_dialog(me.actorId, msg, 2, 2001)
	return

func on_view_model_2001()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_perform")
	return

func effect_20418_perform()->void:
	var se = DataManager.get_current_stratagem_execution()
	var targetId = se.targetId
	var actionId = se.get_action_id(me.actorId)
	ske.cost_war_cd(1)
	se = DataManager.new_stratagem_execution(se.fromId, se.name, ske.skill_name)
	se.set_actioner(actionId)
	se.set_target(targetId)
	se.skip_redo = 1
	# 无消耗，对 AI 流程有作用
	se.cost = -1
	skill_end_clear(true)
	if me.get_controlNo() < 0:
		LoadControl.load_script("war/AI/War_AI_behavior.gd")
		FlowManager.add_flow("AI_stratagem_talk")
	else:
		LoadControl.load_script("war/player_stratagem.gd")
		FlowManager.add_flow("stratagem_animation")
	return
