extends "effect_20000.gd"

#伪溃诱发技 #失败触发 #计伤
#【伪溃】大战场,诱发技。你白刃战败时才能发动。对其造成等同于计策[连弩]的伤害，并恢复1/2因撤退而减少的米和兵力。每个回合限1次。

const EFFECT_ID = 20223
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const STRATAGEM = "连弩"

func on_trigger_20020() -> bool:
	var bf = DataManager.get_current_battle_fight()
	var loser = bf.get_loser()
	if loser == null or loser.actorId != me.actorId:
		# 不是失败方
		return false
	var winner = loser.get_battle_enemy_war_actor()
	if winner == null or not me.is_enemy(winner):
		# 如果我投降了
		# 现在是一家人了，就算了
		return false
	return true

func effect_20223_AI_start():
	goto_step("2")
	return

func effect_20223_start() -> void:
	var bf = DataManager.get_current_battle_fight()
	var targetId = bf.get_attacker_id()
	if targetId == actorId:
		targetId = bf.get_defender_id()

	var msg = "已预布劲弩，发动【{0}】\n挽回战损，并计袭{1}\n可否？".format([
		ske.skill_name, ActorHelper.actor(targetId).get_name()
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_perform", false)
	return

func effect_20223_perform() -> void:
	var bf = DataManager.get_current_battle_fight()
	var targetId = bf.get_attacker().actorId
	if targetId == actorId:
		targetId = bf.get_defender().actorId

	ske.cost_war_cd(1)
	if bf.lostRice > 0:
		ske.change_actor_rice(ske.skill_actorId, int(bf.lostRice / 2))
	if bf.retreatLostSoldier > 0:
		ske.change_actor_soldiers(ske.skill_actorId, int(bf.retreatLostSoldier / 2))
	var msg = "{0}！中吾计也！".format([
		DataManager.get_actor_naughty_title(targetId, actorId),
	])
	report_skill_result_message(ske, 2001, msg, 1)
	return

func on_view_model_2001() -> void:
	wait_for_pending_message(FLOW_BASE + "_report", FLOW_BASE + "_scheme")
	return

func effect_20223_report() -> void:
	report_skill_result_message(ske, 2001)
	return

func effect_20223_scheme() -> void:
	var bf = DataManager.get_current_battle_fight()
	var targetId = bf.get_attacker().actorId
	if targetId == actorId:
		targetId = bf.get_defender().actorId

	var se = DataManager.new_stratagem_execution(actorId, STRATAGEM, ske.skill_name)
	se.work_as_skill = 1
	se.set_target(targetId)
	se.skip_redo = 1
	se.perform_to_targets([targetId], true)
	se.report()

	ske.play_se_animation(se, 2002, "", 0)
	return

func on_view_model_2002() -> void:
	wait_for_pending_message(FLOW_BASE + "_scheme_report", "")
	return

func effect_20223_scheme_report() -> void:
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 2002)
	return
