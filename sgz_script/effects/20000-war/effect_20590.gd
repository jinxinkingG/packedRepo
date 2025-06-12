extends "effect_20000.gd"

# 驽逸主动技
#【驽逸】大战场，主动技。你可消耗10点体力发动。将<读星>描述中的一个数字增加或者减少1，每种数字限改变3次，持续至直到回合结束。

const EFFECT_ID = 20590
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_HP = 10
const DUXING_EFFECT_ID = 20589

func effect_20590_start() -> void:
	if actor.get_hp() <= COST_HP:
		var msg = "体力难支，需 > {0}".format([COST_HP])
		play_dialog(actorId, msg, 3, 2999)
		return
	var vals = ske.get_war_skill_val_int_array(DUXING_EFFECT_ID)
	if vals.size() != 2:
		vals = [1, 6]
	if vals[0] >= 4 and vals[1] <= 3:
		var msg = "对【读星】的调整已达上限\n不可发动"
		play_dialog(actorId, msg, 2, 2999)
		return
	if vals[0] >= 4:
		goto_step("distance")
		return
	if vals[1] <= 3:
		goto_step("range")
		return
	var options = ["计策范围", "距离因子"]
	var msg = "调整【读星】的："
	play_dialog(actorId, msg, 2, 2000, true, options)
	return

func on_view_model_2000() -> void:
	match wait_for_skill_option():
		0:
			goto_step("range")
			return
		1:
			goto_step("distance")
			return
	if Global.is_action_pressed_BY():
		back_to_skill_menu()
	return

func effect_20590_range() -> void:
	var vals = ske.get_war_skill_val_int_array(DUXING_EFFECT_ID)
	if vals.size() != 2:
		vals = [1, 6]
	var rng = vals[0]
	var msg = "【读星】当前增加计策范围：{0}\n消耗 {1} 体力，改为 {2}\n可否？".format([
		rng, COST_HP, rng + 1,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_range_inc")
	return

func effect_20590_distance() -> void:
	var vals = ske.get_war_skill_val_int_array(DUXING_EFFECT_ID)
	if vals.size() != 2:
		vals = [1, 6]
	var distance = vals[1]
	var msg = "【读星】当前距离因子：{0}\n消耗 {1} 体力，改为 {2}\n可否？".format([
		distance, COST_HP, distance - 1,
	])
	play_dialog(actorId, msg, 2, 2002, true)
	return

func on_view_model_2002() -> void:
	wait_for_yesno(FLOW_BASE + "_distance_dec")
	return

func effect_20590_range_inc() -> void:
	var vals = ske.get_war_skill_val_int_array(DUXING_EFFECT_ID)
	if vals.size() != 2:
		vals = [1, 6]
	vals[0] = min(4, vals[0] + 1)
	ske.set_war_skill_val(vals, 1, DUXING_EFFECT_ID)
	ske.cost_hp(COST_HP)
	ske.war_report()
	var msg = "驽马逸足，亦可致远\n（计策范围增加\n（{0}体力 -{1}，现为{2}".format([
		actor.get_name(), COST_HP, actor.get_hp(),
	])
	play_dialog(actorId, msg, 1, 2999)
	return

func effect_20590_distance_dec() -> void:
	var vals = ske.get_war_skill_val_int_array(DUXING_EFFECT_ID)
	if vals.size() != 2:
		vals = [1, 6]
	vals[1] = max(3, vals[1] - 1)
	ske.set_war_skill_val(vals, 1, DUXING_EFFECT_ID)
	ske.cost_hp(COST_HP)
	ske.war_report()
	var msg = "驽马逸足，亦可致远\n（远距离计策成功率提升\n（{0}体力 -{1}，现为{2}".format([
		actor.get_name(), COST_HP, actor.get_hp(),
	])
	play_dialog(actorId, msg, 1, 2999)
	return
