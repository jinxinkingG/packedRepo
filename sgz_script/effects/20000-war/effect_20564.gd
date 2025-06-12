extends "effect_20000.gd"

# 运粮主动技
#【运粮】大战场，主动技。战争攻方才能使用。若进攻前的来源城市仍是你方占据，你可将那座城中任意数量的金、米转移至战场己方。每3回合限1次。

const EFFECT_ID = 20564
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20564_start() -> void:
	var wf = DataManager.get_current_war_fight()
	var wv = me.war_vstate()
	var city = wf.from_city()
	if city.get_vstate_id() != wv.vstateId:
		var msg = "{0}已非我所有".format([
			city.get_full_name(),
		])
		play_dialog(actorId, msg, 3, 2999)
		return
	if city.get_gold() <= 0 and city.get_rice() <= 0:
		var msg = "{0}已无金米可调".format([
			city.get_full_name(),
		])
		play_dialog(actorId, msg, 3, 2999)
		return
	var msg = "从{0}调配多少金米？".format([
		city.get_full_name()
	])
	var gold = min(9999 - wv.money, city.get_gold())
	var rice = min(9999 - wv.rice, city.get_rice())
	var props = ["金", "米"]
	var limits = [gold, rice]
	ske.set_war_skill_val([0, 0])
	SceneManager.show_input_numbers(msg, props, limits)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_multiple_number_input(FLOW_BASE + "_decided")
	return

func effect_20564_decided() -> void:
	var numbers = DataManager.get_env_int_array("多项数值")
	if numbers.size() != 2:
		goto_step("start")
		return
	var gold = numbers[0]
	var rice = numbers[1]
	if gold <= 0 and rice <= 0:
		goto_step("start")
		return

	var wf = DataManager.get_current_war_fight()
	var city = wf.from_city()

	var msg = "从{0}紧急征调\n"
	if gold > 0:
		msg += "{1} 金、"
	if rice > 0:
		msg += "{2} 米"
	msg += "\n可否？"
	msg = msg.format([
		city.get_full_name(), gold, rice,
	])
	ske.set_war_skill_val([gold, rice])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_confirmed")
	return

func effect_20564_confirmed() -> void:
	var wf = DataManager.get_current_war_fight()
	var wv = me.war_vstate()
	var city = wf.from_city()
	var numbers = ske.get_war_skill_val_int_array()
	var gold = numbers[0]
	var rice = numbers[1]

	gold = -ske.change_city_property(city.ID, "金", -gold)
	rice = -ske.change_city_property(city.ID, "米", -rice)
	gold = ske.change_wv_gold(gold)
	rice = ske.change_wv_rice(rice)
	ske.cost_war_cd(3)
	ske.war_report()

	var msg = "战势瞬息万变\n军资自当足备"
	report_skill_result_message(ske, 2002, msg, 1, actorId, false)
	return

func on_view_model_2002() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20564_report() -> void:
	report_skill_result_message(ske, 2002)
	return
