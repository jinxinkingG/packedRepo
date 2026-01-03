extends "effect_20000.gd"

# 自如主动技
#【自如】大战场，主动技。你用伤兵计前，可以选择提高或降低该计策所消耗的机动力任意点数（但计策消耗至少为1）。每提高1点消耗，计策命中率+10%；每降低1点消耗，计策命中率-10%。

const EFFECT_ID = 20649
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20649_start() -> void:
	var x = ske.get_war_skill_val_int()

	var msg = "当前系数{0}，调整为：".format([x])
	SceneManager.show_input_numbers(msg, ["系数"], [9], [0])
	SceneManager.input_numbers.show_actor(actorId)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_number_input(FLOW_BASE + "_adjust", true)
	return

func effect_20649_adjust() -> void:
	var x = DataManager.get_env_int("数值")
	if x == 0:
		var msg = "系数设定为0\n无特殊效果"
		ske.set_war_skill_val(0)
		play_dialog(actorId, msg, 2, 2999)
		return
	var msg = "提高机动力消耗，增加命中率\n反之亦然，如何选择？".format([x])
	var options = ["-{0}".format([x]), "+{0}".format([x])]
	play_dialog(actorId, msg, 2, 2001, true, options)
	return

func on_view_model_2001() -> void:
	var x = DataManager.get_env_int("数值")
	match wait_for_skill_option():
		0:
			DataManager.set_env("数值", -x)
			goto_step("done")
		1:
			goto_step("done")
	return

func effect_20649_done() -> void:
	var x = DataManager.get_env_int("数值")
	var msg = "系数设定为 {0}\n".format([x])
	if x > 0:
		msg += "伤兵计命中率增加 {0}%\n机动力消耗 +{1}".format([
			x * 10, x
		])
	else:
		msg += "伤兵计命中率减少 {0}%\n机动力消耗 {1}，最少为 1".format([
			abs(x * 10), x, 
		])
	ske.set_war_skill_val(x)
	play_dialog(actorId, msg, 2, 2999)
	return

func on_trigger_20005() -> bool:
	var x = ske.get_war_skill_val_int()
	if x == 0:
		return false
	var settings = DataManager.get_env_dict("计策.消耗")
	var scheme = StaticManager.get_stratagem(settings["计策"])
	if scheme == null or not scheme.may_damage_soldier():
		return false
	var cost = int(settings["所需"])
	cost = max(1, cost + x)
	if x < 0:
		reduce_scheme_ap_cost(scheme.name, cost)
	else:
		raise_scheme_ap_cost(scheme.name, cost)
	return false

func on_trigger_20017()->bool:
	var x = ske.get_war_skill_val_int()
	if x == 0:
		return false
	var se = DataManager.get_current_stratagem_execution()
	if ske.actorId == actorId and se.get_action_id(actorId) == actorId:
		# 触发自己，是我用计
		change_scheme_chance(actorId, ske.skill_name, x * 10)
	return false
