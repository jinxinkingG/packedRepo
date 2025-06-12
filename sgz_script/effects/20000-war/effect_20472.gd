extends "effect_20000.gd"

#秘备主动技
#【秘备】大战场，主动技。你可将己方任意数量的金转为等量的[备]标记，或将[备]转为等量的金。

const EFFECT_ID = 20472
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const FLAG_SCENE_ID = 10000
const FLAG_ID = 10025
const FLAG_NAME = "备"

func effect_20472_start()->void:
	var options = ["金换备", "备换金"]
	var msg = "执行什么动作？"
	play_dialog(actorId, msg, 2, 2000, true, options)
	return

func on_view_model_2000()->void:
	match wait_for_skill_option():
		0:
			goto_step("for_flag")
		1:
			goto_step("for_gold")
	return

func effect_20472_for_flag()->void:
	var gold = me.war_vstate().money
	if gold <= 0:
		var msg = "金不足..."
		play_dialog(actorId, msg, 3, 2999)
		return
	var flags = SkillHelper.get_skill_flags_number(FLAG_SCENE_ID, FLAG_ID, actorId, FLAG_NAME)
	if flags >= 10000:
		var msg = "战备充足，不必置换"
		play_dialog(actorId, msg, 1, 2999)
		return

	gold = min(gold, 10000 - flags)
	var msg = "将多少金置换为「备」？"
	SceneManager.show_input_numbers(msg, ["金"], [gold], [0], [4])
	SceneManager.input_numbers.show_actor(actorId)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001()->void:
	wait_for_number_input(FLOW_BASE + "_go_flag")
	return

func effect_20472_go_flag()->void:
	var cost = DataManager.get_env_int("数值")
	if cost > 0:
		cost = -ske.change_wv_gold(-cost)
	var flags = SkillHelper.get_skill_flags_number(FLAG_SCENE_ID, FLAG_ID, actorId, FLAG_NAME)
	if cost > 0:
		ske.cost_skill_flags(FLAG_SCENE_ID, FLAG_ID, FLAG_NAME, -cost)
	flags = SkillHelper.get_skill_flags_number(FLAG_SCENE_ID, FLAG_ID, actorId, FLAG_NAME)
	ske.war_report()
	var msg = "我方金 -{0}\n现有「备」标记{1}".format([
		cost, flags,
	])
	play_dialog(actorId, msg, 2, 2999)
	return

func effect_20472_for_gold()->void:
	var flags = SkillHelper.get_skill_flags_number(FLAG_SCENE_ID, FLAG_ID, actorId, FLAG_NAME)
	if flags <= 0:
		var msg = "「备」不足..."
		play_dialog(actorId, msg, 3, 2999)
		return
	var gold = me.war_vstate().money
	if gold >= 9999:
		var msg = "我方金充足，不必置换"
		play_dialog(actorId, msg, 1, 2999)
		return

	flags = min(flags, 9999 - gold)
	var msg = "将多少「备」置换为金？"
	SceneManager.show_input_numbers(msg, ["「备」"], [flags], [0], [4])
	SceneManager.input_numbers.show_actor(actorId)
	LoadControl.set_view_model(2002)
	return

func on_view_model_2002()->void:
	wait_for_number_input(FLOW_BASE + "_go_gold")
	return

func effect_20472_go_gold()->void:
	var cost = DataManager.get_env_int("数值")
	var flags = SkillHelper.get_skill_flags_number(FLAG_SCENE_ID, FLAG_ID, actorId, FLAG_NAME)
	cost = min(cost, flags)
	if cost > 0:
		cost = ske.cost_skill_flags(FLAG_SCENE_ID, FLAG_ID, FLAG_NAME, cost)
	if cost > 0:
		ske.change_wv_gold(cost)
	flags = SkillHelper.get_skill_flags_number(FLAG_SCENE_ID, FLAG_ID, actorId, FLAG_NAME)
	ske.war_report()
	var msg = "我方金 +{0}\n现有「备」标记{1}".format([
		cost, flags,
	])
	play_dialog(actorId, msg, 2, 2999)
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation()
	return
