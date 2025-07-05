extends "effect_20000.gd"

#正奇主动技
#【正奇】大战场,主动技。选择一个你计策列表中的伤兵类计策，消耗对应机动力的50%进行使用，立即刷新你的的花色进行判定，若为红色，则判定计策成功，否则失败；若为黑桃，你的机动力额外-3。每回合限2次

const EFFECT_ID = 20206
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const EXTRA_COST_AP = 3
const LIMITED_TIMES = 2

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	var top = SceneManager.lsc_menu_top
	if Input.is_action_just_pressed("ANALOG_UP"):
		top.lsc.move_up()
	if Input.is_action_just_pressed("ANALOG_DOWN"):
		top.lsc.move_down()
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		top.lsc.move_left()
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		top.lsc.move_right()
	if Global.is_action_pressed_BY():
		if not SceneManager.dialog_msg_complete(false):
			return
		back_to_skill_menu()
	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	var menu_array = get_env_array("列表值")
	if top.lsc.cursor_index < 0 or top.lsc.cursor_index >= menu_array.size():
		return
	var stratagem = str(menu_array[top.lsc.cursor_index])
	if stratagem == "":
		return
	var se = DataManager.new_stratagem_execution(actorId, stratagem, ske.skill_name)
	if not se.performable():
		return

	LoadControl.set_view_model(-1)
	start_scheme(stratagem)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return

# 兼容并覆盖主流程场景：选择用计目标
func on_view_model_121():
	if Global.is_action_pressed_BY():
		if not SceneManager.dialog_msg_complete(false):
			return
		goto_step("2")
	return

func effect_20206_start():
	if ske.get_war_limited_times() >= LIMITED_TIMES:
		play_dialog(-1, "【正奇】每回合限两次", 2, 2999)
		return
	play_dialog(me.actorId, "兵以正合，策以奇胜", 2, 2000)
	return

#展示计策列表
func effect_20206_2():
	var items = []
	var values = []
	for scheme in me.get_stratagems():
		if not scheme.may_damage_soldier():
			continue
		var ap = int(scheme.get_cost_ap(me.actorId) / 2)
		items.append("{0}({1})".format([scheme.name, ap]))
		values.append(scheme.name)
	var msg = "[正奇]伤兵计消耗减半\n（当前机动力:{0}".format([me.action_point])
	DataManager.set_env("对话", msg)
	SceneManager.show_unconfirm_dialog(msg, me.actorId)
	bind_menu_items(items, values)
	LoadControl.set_view_model(2001)
	return

# 锁定技，如果有技能标记，机动力减半
func on_trigger_20005() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(me.actorId) != me.actorId:
		return false
	if se.skill != ske.skill_name:
		return false
	var cost = int(DataManager.get_env_int("计策.消耗.所需") / 2)
	set_scheme_ap_cost("ALL", cost)
	return false

func on_trigger_20010() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(me.actorId) != me.actorId:
		return false
	if se.skill != ske.skill_name:
		return false
	me.refresh_poker_random()
	match me.five_phases:
		War_Character.FivePhases_Enum.Wood:
			se.set_must_success(me.actorId, ske.skill_name)
		War_Character.FivePhases_Enum.Fire:
			se.set_must_success(me.actorId, ske.skill_name)
		War_Character.FivePhases_Enum.Metal:
			se.set_must_fail(me.actorId, ske.skill_name)
			ske.cost_ap(EXTRA_COST_AP)
			se.append_result(ske.skill_name, "因正奇效果，机动力-3", 3, self.actorId)
		_:
			se.set_must_fail(me.actorId, ske.skill_name)
	ske.cost_war_limited_times(LIMITED_TIMES)
	return false
