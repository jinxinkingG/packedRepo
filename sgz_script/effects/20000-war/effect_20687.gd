extends "effect_20000.gd"

# 猝袭锁定技
#【猝袭】大战场，锁定技。你方回合结束时，你选择你一格范围内非城地形的一个对方武将发动：无消耗对其使用一次计策要击。若成功，结算要击伤害；若失败，你对其发起攻击，且你的步兵和弓兵不参与白刃战。

const EFFECT_ID = 20687
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20016() -> bool:
	var targets = get_enemy_targets(me, false, 1)
	if targets.empty():
		return false
	ske.cost_war_cd(1)
	return true

func effect_20687_start() -> void:
	var targets = get_enemy_targets(me, false, 1)
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected", false, false)
	return

func effect_20687_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	var se = DataManager.new_stratagem_execution(actorId, "要击", ske.skill_name)
	se.set_target(targetId)
	se.perform_to_targets([targetId])
	var msg = "【{0}】对{1}发动要击".format([ske.skill_name, targetWA.get_name()])
	ske.play_se_animation(se, 2002, msg, 0)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_report")
	return

func effect_20687_report() -> void:
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_pending_message(FLOW_BASE + "_report", FLOW_BASE + "_fight")
	return

func effect_20687_fight() -> void:
	var se = DataManager.get_current_stratagem_execution()
	if se.succeeded > 0:
		skill_end_clear()
		return

	ske.mark_auto_finish_turn()
	var targetWA = DataManager.get_war_actor(se.targetId)
	start_battle_and_finish(actorId, se.targetId)
	var msg = "计谋不成，当奋短兵！\n（对{0}发起急袭".format([targetWA.get_name()])
	me.attach_free_dialog(msg, 0)
	return
